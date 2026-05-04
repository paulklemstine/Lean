#!/usr/bin/env python3
"""WebsiteGenerator: Builds a website from all Aristotle results.

Scans the Catalog for artifacts (theorems, papers, demos, visuals, articles,
HTML pages, future directions) and generates a navigable website with:
- Index page with domain navigation and research stats
- Per-domain pages listing all theorems and papers
- Per-result detail pages
- Future Directions aggregation page
- Discussion/SciAm article gallery
- MathJax rendering and D3.js visualizations

Called after each integration cycle to keep the site current.
"""

import os
import re
import shutil
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Set

# Known Catalog domain directories
DOMAIN_DIRS = [
    "Algebra", "Applications", "Bridges", "Computation", "Cryptography",
    "EML", "Geometry", "Logic", "MachineLearning", "Physics",
    "Pythagorean", "Shared", "Speculative", "Tropical",
]


@dataclass
class ArtifactInfo:
    """Metadata about a single Catalog artifact."""
    path: Path
    name: str
    artifact_type: str  # "theorem", "paper", "demo", "visual", "article", "webpage", "future_directions"
    domain: str
    size: int = 0
    modified: str = ""


class WebsiteGenerator:
    """Generate a navigable website from Catalog artifacts."""

    def __init__(self, catalog_root: Path, output_dir: Optional[Path] = None):
        self.catalog_root = Path(catalog_root)
        self.output_dir = Path(output_dir) if output_dir else self.catalog_root / "Applications" / "Web"
        self._artifacts: List[ArtifactInfo] = []

    def generate_site(self) -> str:
        """Main entry point: scan catalog and generate the full site."""
        self._scan_catalog()
        self.output_dir.mkdir(parents=True, exist_ok=True)

        self._generate_css()
        self._generate_index_page()
        self._generate_domain_pages()
        self._generate_future_directions_page()
        self._generate_discussion_gallery()

        index_path = self.output_dir / "index.html"
        print(f"[Website] Generated site at {self.output_dir} ({len(self._artifacts)} artifacts)")
        return str(index_path)

    def _scan_catalog(self) -> None:
        """Scan the Catalog for all artifacts."""
        self._artifacts = []

        # Scan Applications directories
        for subdir in ["Papers", "Demos", "Visuals", "Articles", "Web"]:
            app_dir = self.catalog_root / "Applications" / subdir
            if app_dir.exists():
                for f in app_dir.iterdir():
                    if f.is_file() and not f.name.startswith("."):
                        self._add_artifact(f, subdir.lower().rstrip("s"))

        # Scan domain directories for .lean files
        for domain in DOMAIN_DIRS:
            domain_dir = self.catalog_root / domain
            if domain_dir.exists():
                for f in domain_dir.rglob("*.lean"):
                    if f.is_file() and not f.name.startswith("."):
                        self._add_artifact(f, "theorem", domain)

        # Scan ResearchOutput
        ro_dir = self.catalog_root / "ResearchOutput"
        if ro_dir.exists():
            for f in ro_dir.rglob("*"):
                if f.is_file() and not f.name.startswith("."):
                    suffix = f.suffix.lower()
                    if suffix == ".lean":
                        self._add_artifact(f, "theorem")
                    elif suffix == ".md":
                        self._add_artifact(f, "paper")
                    elif suffix == ".py":
                        self._add_artifact(f, "demo")
                    elif suffix == ".html":
                        self._add_artifact(f, "webpage")
                    elif suffix in (".svg", ".png"):
                        self._add_artifact(f, "visual")

    def _add_artifact(self, f: Path, artifact_type: str, domain: str = "") -> None:
        """Add an artifact to the list."""
        if not domain:
            domain = self._infer_domain(f)
        try:
            stat = f.stat()
            modified = datetime.fromtimestamp(stat.st_mtime).strftime("%Y-%m-%d")
            size = stat.st_size
        except Exception:
            modified = ""
            size = 0
        self._artifacts.append(ArtifactInfo(
            path=f, name=f.name, artifact_type=artifact_type,
            domain=domain, size=size, modified=modified,
        ))

    def _infer_domain(self, f: Path) -> str:
        """Infer the domain from the file path."""
        parts = f.relative_to(self.catalog_root).parts
        for p in parts:
            if p in DOMAIN_DIRS:
                return p
            p_lower = p.lower()
            for d in DOMAIN_DIRS:
                if d.lower() == p_lower:
                    return d
        return "General"

    def _generate_css(self) -> None:
        """Generate shared CSS."""
        css = """/* Aether Research Website */
:root {
  --bg: #0d1117; --fg: #c9d1d9; --accent: #58a6ff;
  --card: #161b22; --border: #30363d; --muted: #8b949e;
  --success: #3fb950; --warning: #d29922; --danger: #f85149;
}
* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
       background: var(--bg); color: var(--fg); line-height: 1.6; }
a { color: var(--accent); text-decoration: none; }
a:hover { text-decoration: underline; }
.container { max-width: 1200px; margin: 0 auto; padding: 20px; }
.grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 16px; }
.card { background: var(--card); border: 1px solid var(--border); border-radius: 8px;
       padding: 16px; transition: transform 0.2s; }
.card:hover { transform: translateY(-2px); }
.card h3 { margin-bottom: 8px; font-size: 1.1em; }
.card p { color: var(--muted); font-size: 0.9em; }
.badge { display: inline-block; padding: 2px 8px; border-radius: 12px; font-size: 0.75em;
         font-weight: 600; margin-right: 4px; }
.badge-theorem { background: #1f6feb33; color: var(--accent); }
.badge-paper { background: #3fb95033; color: var(--success); }
.badge-demo { background: #d2992233; color: var(--warning); }
.badge-article { background: #bc4c0033; color: #f0883e; }
.badge-webpage { background: #a371f733; color: #a371f7; }
nav { background: var(--card); border-bottom: 1px solid var(--border);
      padding: 12px 0; margin-bottom: 20px; }
nav a { margin-right: 16px; font-weight: 500; }
h1 { font-size: 1.8em; margin-bottom: 16px; }
h2 { font-size: 1.4em; margin: 24px 0 12px; color: var(--accent); }
.stats { display: flex; gap: 16px; flex-wrap: wrap; margin-bottom: 24px; }
.stat { background: var(--card); border: 1px solid var(--border); border-radius: 8px;
        padding: 16px 24px; text-align: center; }
.stat .number { font-size: 2em; font-weight: 700; color: var(--accent); }
.stat .label { color: var(--muted); font-size: 0.85em; }
.domain-list { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 20px; }
.domain-chip { padding: 6px 14px; border-radius: 20px; font-size: 0.85em;
              background: var(--card); border: 1px solid var(--border); }
.domain-chip:hover { border-color: var(--accent); }
footer { margin-top: 40px; padding: 20px 0; border-top: 1px solid var(--border);
         color: var(--muted); font-size: 0.85em; text-align: center; }
"""
        (self.output_dir / "style.css").write_text(css, encoding="utf-8")

    def _html_head(self, title: str) -> str:
        """Generate HTML <head> with MathJax and D3.js."""
        return f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{title} — Aether Research</title>
<link rel="stylesheet" href="style.css">
<script>
MathJax = {{
  tex: {{ inlineMath: [['$', '$'], ['\\\\(', '\\\\)']] }},
  svg: {{ fontCache: 'global' }}
}};
</script>
<script async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js"></script>
<script src="https://d3js.org/d3.v7.min.js"></script>
</head>
<body>
<nav><a href="index.html">Home</a> <a href="future_directions.html">Future Directions</a>
<a href="discussions.html">Articles</a></nav>
<div class="container">
"""

    def _html_foot(self) -> str:
        """Generate HTML footer."""
        return """</div>
<footer>Generated by Aether Website Generator &mdash; Autonomous Mathematical Research Engine</footer>
</body></html>"""

    def _generate_index_page(self) -> None:
        """Generate the top-level dashboard page."""
        # Compute stats
        domain_counts: Dict[str, Dict[str, int]] = {}
        for a in self._artifacts:
            if a.domain not in domain_counts:
                domain_counts[a.domain] = {}
            domain_counts[a.domain][a.artifact_type] = domain_counts[a.domain].get(a.artifact_type, 0) + 1

        type_counts: Dict[str, int] = {}
        for a in self._artifacts:
            type_counts[a.artifact_type] = type_counts.get(a.artifact_type, 0) + 1

        total = len(self._artifacts)

        # Build stats section
        stats_html = '<div class="stats">\n'
        stats_html += f'<div class="stat"><div class="number">{total}</div><div class="label">Total Artifacts</div></div>\n'
        for t in ["theorem", "paper", "demo", "article", "webpage"]:
            c = type_counts.get(t, 0)
            if c > 0:
                stats_html += f'<div class="stat"><div class="number">{c}</div><div class="label">{t.title()}s</div></div>\n'
        stats_html += '</div>\n'

        # Domain chips
        domain_chips = '<div class="domain-list">\n'
        for domain in sorted(domain_counts.keys()):
            count = sum(domain_counts[domain].values())
            domain_chips += f'<a class="domain-chip" href="domain_{domain.lower()}.html">{domain} ({count})</a>\n'
        domain_chips += '</div>\n'

        # Recent artifacts grid
        recent = sorted(self._artifacts, key=lambda a: a.modified or "0", reverse=True)[:30]
        cards_html = '<div class="grid">\n'
        for a in recent:
            badge_class = f"badge-{a.artifact_type}"
            cards_html += (
                f'<div class="card">'
                f'<span class="badge {badge_class}">{a.artifact_type}</span> '
                f'<span style="color:var(--muted);font-size:0.8em">{a.domain}</span>'
                f'<h3>{a.name}</h3>'
                f'<p>Modified: {a.modified or "unknown"} | Size: {a.size:,} bytes</p>'
                f'</div>\n'
            )
        cards_html += '</div>\n'

        # Master FUTURE_DIRECTIONS content
        master_fd_path = self.catalog_root / "Aether" / ".aether_workspace" / "MASTER_FUTURE_DIRECTIONS.md"
        master_fd_section = ""
        if master_fd_path.exists():
            try:
                content = master_fd_path.read_text(encoding="utf-8", errors="replace")[:3000]
                # Convert markdown to rough HTML
                content_html = self._md_to_html(content)
                master_fd_section = (
                    '<h2>Accumulated Research Wisdom</h2>\n'
                    f'<div style="background:var(--card);border:1px solid var(--border);'
                    f'border-radius:8px;padding:16px;max-height:400px;overflow:auto;">'
                    f'{content_html}</div>\n'
                )
            except Exception:
                pass

        html = self._html_head("Dashboard")
        html += f"""<h1>Aether Research Dashboard</h1>
<p>Autonomous mathematical research engine — theorems, papers, and discoveries.</p>
{stats_html}
<h2>Research Domains</h2>
{domain_chips}
<h2>Recent Artifacts</h2>
{cards_html}
{master_fd_section}
"""
        html += self._html_foot()

        (self.output_dir / "index.html").write_text(html, encoding="utf-8")

    def _generate_domain_pages(self) -> None:
        """Generate per-domain pages."""
        domain_artifacts: Dict[str, List[ArtifactInfo]] = {}
        for a in self._artifacts:
            domain_artifacts.setdefault(a.domain, []).append(a)

        for domain, artifacts in domain_artifacts.items():
            # Count types
            type_counts: Dict[str, int] = {}
            for a in artifacts:
                type_counts[a.artifact_type] = type_counts.get(a.artifact_type, 0) + 1

            # Stats
            stats_html = '<div class="stats">\n'
            for t, c in sorted(type_counts.items()):
                stats_html += f'<div class="stat"><div class="number">{c}</div><div class="label">{t.title()}s</div></div>\n'
            stats_html += '</div>\n'

            # Artifact cards
            cards_html = '<div class="grid">\n'
            for a in sorted(artifacts, key=lambda x: x.name):
                badge_class = f"badge-{a.artifact_type}"
                cards_html += (
                    f'<div class="card">'
                    f'<span class="badge {badge_class}">{a.artifact_type}</span>'
                    f'<h3>{a.name}</h3>'
                    f'<p>Modified: {a.modified or "unknown"} | {a.size:,} bytes</p>'
                    f'</div>\n'
                )
            cards_html += '</div>\n'

            html = self._html_head(domain)
            html += f"""<h1>{domain}</h1>
<p>{len(artifacts)} artifacts in the {domain} domain.</p>
{stats_html}
<h2>All Artifacts</h2>
{cards_html}
"""
            html += self._html_foot()

            (self.output_dir / f"domain_{domain.lower()}.html").write_text(html, encoding="utf-8")

    def _generate_future_directions_page(self) -> None:
        """Generate the Future Directions aggregation page."""
        # Collect all future directions files
        fd_files = []
        for a in self._artifacts:
            if a.artifact_type == "future_directions" or "future_directions" in a.name.lower():
                fd_files.append(a)

        sections_html = ""

        # Master file first
        master_fd_path = self.catalog_root / "Aether" / ".aether_workspace" / "MASTER_FUTURE_DIRECTIONS.md"
        if master_fd_path.exists():
            try:
                content = master_fd_path.read_text(encoding="utf-8", errors="replace")
                sections_html += (
                    '<h2>Accumulated Research Wisdom</h2>\n'
                    f'<div style="background:var(--card);border:1px solid var(--border);'
                    f'border-radius:8px;padding:16px;margin-bottom:24px;">'
                    f'{self._md_to_html(content)}</div>\n'
                )
            except Exception:
                pass

        # Individual files
        for a in fd_files:
            try:
                content = a.path.read_text(encoding="utf-8", errors="replace")[:5000]
                sections_html += (
                    f'<h3>{a.name}</h3>\n'
                    f'<div style="background:var(--card);border:1px solid var(--border);'
                    f'border-radius:8px;padding:16px;margin-bottom:16px;">'
                    f'{self._md_to_html(content)}</div>\n'
                )
            except Exception:
                pass

        if not sections_html:
            sections_html = '<p>No future directions have been generated yet. Run more research cycles!</p>'

        html = self._html_head("Future Directions")
        html += f"""<h1>Future Research Directions</h1>
<p>Accumulated wisdom from all Aristotle research cycles. Each completed cycle produces
a FUTURE_DIRECTIONS.md with breakthrough opportunities, open problems, and cross-domain bridges.</p>
{sections_html}
"""
        html += self._html_foot()

        (self.output_dir / "future_directions.html").write_text(html, encoding="utf-8")

    def _generate_discussion_gallery(self) -> None:
        """Generate the Scientific American-style article gallery."""
        articles = [a for a in self._artifacts if a.artifact_type == "article"]

        if not articles:
            html = self._html_head("Articles")
            html += """<h1>Research Articles</h1>
<p>No discussion articles have been generated yet.</p>"""
            html += self._html_foot()
            (self.output_dir / "discussions.html").write_text(html, encoding="utf-8")
            return

        cards_html = '<div class="grid">\n'
        for a in articles:
            try:
                preview = a.path.read_text(encoding="utf-8", errors="replace")[:300]
                preview = preview.replace("<", "&lt;").replace(">", "&gt;")
            except Exception:
                preview = ""
            cards_html += (
                f'<div class="card">'
                f'<span class="badge badge-article">article</span>'
                f'<span style="color:var(--muted);font-size:0.8em">{a.domain}</span>'
                f'<h3>{a.name}</h3>'
                f'<p style="color:var(--fg)">{preview}...</p>'
                f'</div>\n'
            )
        cards_html += '</div>\n'

        html = self._html_head("Articles")
        html += f"""<h1>Research Articles</h1>
<p>Scientific American-style popular science articles from each research cycle.</p>
{cards_html}
"""
        html += self._html_foot()

        (self.output_dir / "discussions.html").write_text(html, encoding="utf-8")

    @staticmethod
    def _md_to_html(md_text: str) -> str:
        """Convert basic markdown to HTML for inline display."""
        html = md_text
        html = html.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
        # Headers
        html = re.sub(r'^### (.+)$', r'<h3>\1</h3>', html, flags=re.MULTILINE)
        html = re.sub(r'^## (.+)$', r'<h2>\1</h2>', html, flags=re.MULTILINE)
        html = re.sub(r'^# (.+)$', r'<h1>\1</h1>', html, flags=re.MULTILINE)
        # Bold and italic
        html = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', html)
        html = re.sub(r'\*(.+?)\*', r'<em>\1</em>', html)
        # Code
        html = re.sub(r'`(.+?)`', r'<code>\1</code>', html)
        # Lists
        html = re.sub(r'^- (.+)$', r'<li>\1</li>', html, flags=re.MULTILINE)
        html = re.sub(r'^(\d+)\. (.+)$', r'<li>\2</li>', html, flags=re.MULTILINE)
        # Paragraphs
        html = re.sub(r'\n\n', '</p><p>', html)
        html = f'<p>{html}</p>'
        return html


if __name__ == "__main__":
    import sys
    catalog_root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("../Catalog")
    gen = WebsiteGenerator(catalog_root)
    gen.generate_site()
    print(f"Site generated at {gen.output_dir}")