#!/usr/bin/env bash
# Génère les images (PNG + SVG) des diagrammes UML à partir de docs/uml.md.
# Prérequis : Node.js installé. Aucune installation manuelle : npx télécharge l'outil.
#
# Usage :
#   bash docs/render-uml.sh
#
# Sortie : docs/diagrams/uml-1.png ... uml-N.png  (et .svg)
# (un fichier par diagramme du Markdown)

set -e
cd "$(dirname "$0")/.."
mkdir -p docs/diagrams
echo '{ "args": ["--no-sandbox"] }' > .pptr.json

echo "→ Rendu PNG…"
npx -y @mermaid-js/mermaid-cli@11 -p .pptr.json -b white -i docs/uml.md -o docs/diagrams/uml.png

echo "→ Rendu SVG…"
npx -y @mermaid-js/mermaid-cli@11 -p .pptr.json -b transparent -i docs/uml.md -o docs/diagrams/uml.svg

rm -f .pptr.json
echo "✅ Images générées dans docs/diagrams/"
