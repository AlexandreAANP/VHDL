rm .\cr-trab5.log
rm .\cr-trab5.aux
rm .\cr-trab5.toc
rm .\cr-trab5.out
pdflatex .\cr-trab5.tex
pdflatex .\cr-trab5.tex

if ($LASTEXITCODE -eq 0) {
    # Replace this with the function or command you want to execute
    #DELETE ALL LOG FILES
    # rm .\cr-trab5.log
    # rm .\cr-trab5.aux
    # rm .\cr-trab5.toc
    # rm .\cr-trab5.out
} else {
    Write-Output "The program failed to run."
}