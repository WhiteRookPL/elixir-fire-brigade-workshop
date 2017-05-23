#!/bin/bash

cat list_of_books_with_authors.csv | sort | cut -d'$' -f2 | awk 'BEGIN {i=0} {printf("echo \"%s\" > books/%d.book\n", $0, i++)}' | bash
cat list_of_books_with_authors.csv | sort | awk -F'$' 'BEGIN {i=0} {if ($1 in authors) { prev = authors[$1]; authors[$1] = sprintf("%s,%d", prev, i++) } else { authors[$1] = sprintf("%d", i++) }} END { idx = 0; for(author in authors) { printf("echo -e \"%s\\n%s\" > authors/%d.author\n", author, authors[author], idx++)} }' | bash