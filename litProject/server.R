library(shiny)
library(tesseract)
library(magick)

# Define server
server <- function(input, output) {
  converted_text <- reactiveVal(NULL)
  
  observeEvent(input$convert_btn, {
    req(input$pdf_file)
    pdf_file_path <- input$pdf_file$datapath
    
    # Convert PDF to PNG
    png_files <- pdftools::pdf_convert(pdf_file_path, dpi = 600)
    
    # Create directory for images if not exists
    if (!dir.exists("images")) {
      dir.create("images")
    }
    
    # Move PNG files to images directory
    file.copy(from = png_files, to = "./images", overwrite = TRUE)
    
    # Process PNG files using Magick package
    input_images <- lapply(png_files, magick::image_read)
    
    # Setting up the Tesseract OCR engine
    eng <- tesseract::tesseract("eng")
    
    # Function for generating TXT files from PNG files
    generate_txt <- function(input){
      input |>
        magick::image_resize("2000x") |>
        magick::image_convert(type = "Grayscale") |>
        tesseract::ocr(engine = eng)
    }
    
    # Create directory for TXT files if not exists
    if (!dir.exists("texts")) {
      dir.create("texts")
    }
    
    # Loop through image directory
    for (j in seq_along(input_images)) {
      file_conn <- file(paste0("./texts/text_", j, ".txt"))
      writeLines(generate_txt(input_images[[j]]), file_conn)
      close(file_conn)
    }
    
    converted_text(readLines(paste0("./texts/text_", 1:length(input_images), ".txt")))
  })
  
  output$download_txt <- downloadHandler(
    filename = function() {
      paste("converted_text", ".txt", sep = "")
    },
    content = function(file) {
      writeLines(converted_text(), file)
    }
  )
  
  output$status <- renderText({
    if (!is.null(converted_text())) {
      "Conversion completed. You can download the TXT file now."
    } else {
      ""
    }
  })
}