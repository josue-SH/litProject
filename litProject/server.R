library(shiny)
library(shinyjs)
library(tesseract)
library(magick)
library(zip)

# Define server
server <- function(input, output) {
  #converted_text <- reactiveVal(NULL)
  
  observeEvent(input$convert_btn, {
    req(input$pdf_file)
    pdf_file_path <- input$pdf_file$datapath
    
    # Create a temporary directory
    temp_dir <- tempdir()
    dir.create(temp_dir, showWarnings = FALSE)
    setwd(temp_dir)
    
    # Convert PDF to PNG
    png_files <- pdftools::pdf_convert(pdf_file_path, dpi = 600)
    
    # Process PNG files using Magick package
    magick_images <- lapply(png_files, magick::image_read)
    
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
    for (j in seq_along(magick_images)) {
      file_conn <- file(paste0("./texts/text_", j, ".txt"))
      writeLines(generate_txt(magick_images[[j]]), file_conn)
      close(file_conn)
    }
    
    zip_file <- zip::zip(zipfile = "textFiles.zip", 
                        list.files(temp_dir, full.names = TRUE))
    
    #converted_text(readLines(paste0("./texts/text_", 1:length(magick_images), ".txt")))
    
    #file.remove(png_files)
    #file.remove(list.files("./texts"))
  
    output$download_txt <- downloadHandler(
      filename = function() {
        paste("converted_text", ".zip", sep = "")
      },
      content = function(file) {
        file.copy(zip_file, file)
      }
    )
    
    # Enable download button
    shinyjs::enable("download_zip")
    
    })
  
  # Disable the download button intially
  shinyjs::disable("download_zip")
  
}