mod api_keys;
mod authentication;
mod bulk_import;
mod config;
mod console;
mod datasets;
mod documents;
mod email;
mod errors;
mod layout;
mod models;
mod profile;
mod prompts;
mod registration_handler;
mod rls;
mod static_files;
mod team;
mod training;
mod unstructured;

use axum::extract::Extension;
use axum::{response::Html, routing::get};
use std::net::SocketAddr;
use tower_http::trace::TraceLayer;

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::INFO)
        .init();

    let config = config::Config::new();
    let addr = SocketAddr::from(([0, 0, 0, 0], config.port));

    let config = config::Config::new();
    let pool = db::create_pool(&config.app_database_url);

    let axum_make_service = axum::Router::new()
        .route("/static/*path", get(static_files::static_path))
        .merge(team::routes())
        .merge(profile::routes())
        .merge(registration_handler::routes())
        .merge(console::routes())
        .merge(api_keys::routes())
        .merge(datasets::routes())
        .merge(documents::routes())
        .merge(bulk_import::routes())
        .merge(models::routes())
        .merge(training::routes())
        .merge(prompts::routes())
        .layer(TraceLayer::new_for_http())
        .layer(Extension(config))
        .layer(Extension(pool.clone()))
        .into_make_service();

    tracing::info!("listening on {}", addr);
    let server = hyper::Server::bind(&addr).serve(axum_make_service);

    if let Err(e) = server.await {
        tracing::error!("server error: {}", e);
    }
}

pub fn render<F>(f: F) -> Html<&'static str>
where
    F: FnOnce(&mut Vec<u8>) -> Result<(), std::io::Error>,
{
    let mut buf = Vec::new();
    f(&mut buf).expect("Error rendering template");
    let html: String = String::from_utf8_lossy(&buf).into();

    Html(Box::leak(html.into_boxed_str()))
}
