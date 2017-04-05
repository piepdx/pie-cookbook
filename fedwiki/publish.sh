# publish welcome and pages to public site replacing all existing content
# usage: sh publish.sh

ssh asia 'rm .wiki/pie.fed.wiki/pages/*'
scp pages/* asia:.wiki/pie.fed.wiki/pages
ssh asia 'rm .wiki/pie.fed.wiki/status/sitemap.*'
