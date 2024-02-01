library(shiny)
library(shinyjs)
library(tesseract)
library(magick)
library(zip)

# Define server
server <- function(input, output) {
  
  observeEvent(input$convert_btn, {
    req(input$pdf_file)
    pdf_file_path <- input$pdf_file$datapath
    
    # Create a temporary directory
    #shiny_dir <- tempdir(check = TRUE)
    #setwd(shiny_dir)
    
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
    
    # Loop through image directory
    for (j in seq_along(magick_images)) {
      file_conn <- file(paste0("text_", j, ".txt"))
      writeLines(generate_txt(magick_images[[j]]), file_conn)
      close(file_conn)
    }
    
    # Enable download button
    shinyjs::enable("download_txt")
    
    })
  
  # Create and download zip file of only txt files
  output$download_txt <- downloadHandler(
    filename = "converted_txt.zip",
    content = function(file) {
      zip::zip(file, 
               list.files(pattern = "text_",full.names = TRUE),
               mode = "cherry-pick")
    },
    contentType = "application/zip"
  )
  
  # Disable the download button initially
  shinyjs::disable("download_txt")
  
}