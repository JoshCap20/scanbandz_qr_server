use actix_web::{web, App, HttpRequest, HttpServer, Responder, HttpResponse};
use qrcode::QrCode;
use qrcode::render::svg;
use base64::engine::general_purpose::STANDARD;
use base64::Engine;

async fn generate_qr(req: HttpRequest) -> impl Responder {
    let query_string = req.query_string();

    // Check query string is not empty
    if query_string.is_empty() {
        return HttpResponse::BadRequest().body("Query string is empty");
    }

    // Check length is between 10 and 75 characters
    if query_string.len() < 50 || query_string.len() > 1000 {
        return HttpResponse::BadRequest().body("Invalid query string");
    }

    match QrCode::new(query_string) {
        Ok(code) => {
            let svg = code.render::<svg::Color>()
                .min_dimensions(200, 200)
                .max_dimensions(400, 400)
                .build();
            
            let response = format!(
                "<img src=\"data:image/svg+xml;base64,{}\">",
                STANDARD.encode(svg)
            );

            HttpResponse::Ok()
                .content_type("text/html; charset=utf-8")
                .body(response)
        }
        Err(_) => HttpResponse::InternalServerError().body("Failed to generate QR code"),
    }
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            .route("/generate", web::get().to(generate_qr))
    })
    .workers(num_cpus::get() * 2)  // Number of worker threads
    .bind("0.0.0.0:8080")?
    .run()
    .await
}