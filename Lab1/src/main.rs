use std::env::VarError;
use std::num::ParseIntError;
use std::time::SystemTimeError;
use sqlx::{PgConnection, postgres::PgPool};

#[derive(thiserror::Error, Debug)]
enum MyError {
    #[error(transparent)]
    Db(#[from] sqlx::Error),
    #[error(transparent)]
    SystemTime(#[from] SystemTimeError),
    #[error(transparent)]
    Var(#[from] VarError),
    #[error(transparent)]
    ParseInt(#[from] ParseIntError),
    #[error(transparent)]
    SerdeJson(#[from] serde_json::Error)
}


#[tokio::main]
async fn main() -> Result<(), MyError> {

    dotenvy::dotenv().ok();
    let database_url =  std::env::var("DATABASE_URL")?;
    let total_checks = std::env::var("TOTAL_CHECKS")?.parse::<usize>()?;

    let pool = PgPool::connect(&database_url).await?;
    let mut conn = pool.acquire().await?;

    macro_rules! async_vv_funcs {
        ($($func:ident),*$(,)?) => {{
            [
                $({
                    let mut row_based = 0.0;
                    let mut column_based = 0.0;
                    for _ in 0..total_checks {
                        row_based += $func(&mut conn, "").await? as f64;
                        column_based += $func(&mut conn, "_c").await? as f64;
                    }
                    row_based /= total_checks as f64;
                    column_based /= total_checks as f64;

                    serde_json::json!({
                        "func": std::stringify!($func),
                        "millis": {
                            "row_based": row_based,
                            "column_based": column_based,
                        }
                    })
                },)*
            ]
        }}
    }

    let results = async_vv_funcs!(
        total_delay_by_cities,
        total_flights_by_cities,
        min_delay_by_cities,
        max_delay_by_cities,
        total_flights_by_cities
    );

    let res = serde_json::json!({"results":results});
    println!("{}", serde_json::to_string_pretty(&res)?);

    Ok(())
}

async fn total_delay_by_cities(conn: &mut PgConnection, suffix: &str) -> Result<u32, MyError> {
    let now = std::time::SystemTime::now();

    let query = format!("
        select a.city as city, SUM(f.late_aircraft_delay) as total_delay from flights{} as f
        inner join airports as a on a.iata_code = f.dest
        group by city
    ", suffix);

    sqlx::query(&query).execute(conn).await?;

    Ok(std::time::SystemTime::now().duration_since(now)?.as_millis() as u32)
}

async fn total_flights_by_cities(conn: &mut PgConnection, suffix: &str) -> Result<u32, MyError> {
    let now = std::time::SystemTime::now();

    let query = format!("
        select a.city as city, SUM(f.id) as total_flights from flights{} as f
        inner join airports as a on a.iata_code = f.dest
        group by city
    ", suffix);

    sqlx::query(&query).execute(conn).await?;

    Ok(std::time::SystemTime::now().duration_since(now)?.as_millis() as u32)
}

async fn minmax_delay_by_cities(conn: &mut PgConnection, is_max: bool, suffix: &str) -> Result<u32, MyError> {
    let minmax = if is_max { "MAX" } else { "MIN" };

    let now = std::time::SystemTime::now();

    let query = format!("
        with t as (
            select a.city as city, SUM(f.late_aircraft_delay) as total_delay from flights{} as f
            inner join airports{} as a on a.iata_code = f.dest
            group by city
        )
        select city, total_delay from t where total_delay = (SELECT {}(total_delay) from t LIMIT 1)
    ", suffix, suffix, minmax);

    sqlx::query(&query).execute(conn).await?;

    Ok(std::time::SystemTime::now().duration_since(now)?.as_millis() as u32)
}

async fn min_delay_by_cities(conn: &mut PgConnection, suffix: &str) -> Result<u32, MyError> {
    minmax_delay_by_cities(conn, false, suffix).await
}

async fn max_delay_by_cities(conn: &mut PgConnection, suffix: &str) -> Result<u32, MyError> {
    minmax_delay_by_cities(conn, true, suffix).await
}

async fn more_than_median(conn: &mut PgConnection, suffix: &str) -> Result<u32, MyError> {
    let now = std::time::SystemTime::now();

    let query = format!("
        select f.id from flights{} as f
        where f.id > (SELECT PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY flights{}.late_aircraft_delay) FROM flights{})
    ", suffix, suffix, suffix);

    sqlx::query(&query).execute(conn).await?;

    Ok(std::time::SystemTime::now().duration_since(now)?.as_millis() as u32)
}

