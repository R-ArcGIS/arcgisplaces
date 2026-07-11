default:
    just --list

readme:
    quarto render README.Rmd --to gfm

update:
    git add . && git commit -m "update" && git push
