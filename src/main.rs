use actix_web::{web, App, HttpRequest, HttpServer, Responder, HttpResponse};
use qrcode::QrCode;
use qrcode::render::svg;
use std::io::Cursor;
use base64::{encode, STANDARD};

async fn generate_qr(req: HttpRequest) -> impl Responder {
    let query_string = req.query_string();
    if query_string.is_empty() {
        return HttpResponse::BadRequest().body("Query string is empty");
    }

    match QrCode::new(query_string) {
        Ok(code) => {
            let svg = code.render::<svg::Color>()
                .min_dimensions(200, 200)
                .max_dimensions(400, 400)
                .build();
            
            let response = format!(
                "<html><body><img src=\"data:image/svg+xml;base64,{}\"></body></html>",
                encode(svg)
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
    .bind("127.0.0.1:8080")?
    .run()
    .await
}
