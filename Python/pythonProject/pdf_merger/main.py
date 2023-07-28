import random
import string
import PyPDF2


if __name__ == '__main__':
    pdf_files = ["sample.pdf","sample1.pdf","sample2.pdf"]
    merger = PyPDF2.PdfMerger() # crating a variable to append pdf's into it by using method
    for file in pdf_files:
        pdf_file = open(file, "rb") # open each file in binary format
        pdf_reader = PyPDF2.PdfReader(pdf_file) # read the file using pdf reader
        merger.append(pdf_reader) # append pdf into merger variable
    pdf_file.close() # close binary file

    #output_filename = input("Please enter the output file name:\n")
    N = 5
    res = ''.join(random.choices(string.ascii_letters, k=N))
    merger.write(f'merged_{res}.pdf') #writing into final pdf file

