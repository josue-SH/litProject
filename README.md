# PDFtoTXT Converter

This repository contains the code for a .pdf to .txt file converter app. You can view the published version [here](https://josue-sh.shinyapps.io/pdf_to_text/), although it does not work right now due to the memory contraints of the free version of shiny.io.

I created a version of this app for a course I was helping develop as an Academic Intern at Amherst College. I decided to make a more user-friendly version of that project, and developed this shiny app for ease of use. 

### Description

This project uses the [Tesseract OCR](https://cran.r-project.org/web/packages/tesseract/index.html) and magick packages in R to convert .pdf files to .png files, which are then read by the optical recognition engine and written as .txt files.

### Installation
Use the app by downloading this repository and running it locally on RStudio.

Alternatively, you can run this code on your console to download the app and run it.

```r
  shiny::runGitHub("litProject", "josue-SH", subdir = "litProject")

```

### Usage

Upload a pdf file from your computer onto the shiny app. Then click on the "Convert to TXT" button. I'm not sure what the maximum number of pages it will convert is. When the app is done with reading the pdf files and running the OCR, the download button will activate and the .txt files can be downloaded as a zip file by pressing it.

### Roadmap

There's a few app functionalities that I would like to add:

* Switching languages for the tesseract engine
* Converting directly from URLs

