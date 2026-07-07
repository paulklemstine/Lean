#!/usr/bin/env python3
"""ArxivTexProvider: Fetch recent math papers from ArXiv and extract LaTeX source.

Provides domain-specific and general queries to pull recent papers,
download their source, and extract .tex content for Pi-Agent analysis.
"""

import gzip
import io
import tarfile
import time
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional


# Domain-specific ArXiv queries mapped to Aether research domains.
# Broader queries catch more relevant work — category-only queries are preferred
# over narrow AND queries that miss related papers.
DOMAIN_QUERIES = {
    "Pythagorean": 'cat:math.NT',
    "Tropical": 'cat:math.CO OR all:"tropical" OR all:"min-plus" OR all:"idempotent semiring"',
    "Cryptography": 'cat:cs.CR OR all:"post-quantum" OR all:"lattice-based"',
    "Algebra": 'cat:math.RA OR cat:math.AC OR all:"semiring" OR all:"group theory"',
    "EML": 'all:"exponential" AND all:"logarithmic" OR all:"softplus" OR all:"activation function"',
    "MachineLearning": 'cat:cs.LG OR all:"certified robustness" OR all:"neural network verification"',
    "Physics": 'cat:math-ph OR all:"Hamiltonian" OR all:"quantum field"',
    "Logic": 'cat:cs.LO OR all:"formal verification" OR all:"proof assistant" OR all:"dependent type"',
    "Computation": 'cat:cs.CC OR all:"computational complexity" OR all:"computability"',
    "Bridges": 'all:"interdisciplinary" OR all:"cross-domain" OR all:"bridge theorem" OR all:"connection between"',
    "Speculative": 'all:"speculative" OR all:"hypothetical" OR all:"conjecture" OR all:"open problem"',
    "Geometry": 'cat:math.AG OR cat:math.DG OR all:"manifold" OR all:"algebraic geometry" OR all:"topology"',
    "Novelty": 'all:"surprising" OR all:"unexpected" OR all:"counterexample" OR all:"paradox"',
    "NumberTheory": 'cat:math.NT OR all:"Diophantine" OR all:"arithmetic" OR all:"zeta function"',
}

# Rotating general queries for cross-pollination — one per cycle
GENERAL_QUERIES = [
    'cat:math.NT OR cat:math.CO',                                          # Number theory + combinatorics
    'cat:cs.CR OR cat:cs.LG',                                               # Crypto + ML
    'cat:math.RA OR cat:math.AC',                                           # Algebra + category theory
    'cat:math-ph OR cat:math.DG',                                           # Math physics + diff geometry
    'cat:cs.LO OR cat:cs.CC',                                               # Logic + complexity
    'all:"formalization" OR all:"Lean" OR all:"proof assistant"',           # Formalization frontier
    'all:"conjecture" OR all:"open problem"',                               # Open problems
    'all:"tropical" OR all:"min-plus" OR all:"idempotent"',                # Tropical math
]

# Backward-compatible default general query
GENERAL_QUERY = GENERAL_QUERIES[0]

# Default config values
DEFAULT_RATE_LIMIT = 3  # seconds between downloads
DEFAULT_MAX_PAPER_CHARS = 40000  # increased for structural extraction
DEFAULT_BATCH_SIZE = 20  # increased for relevance ranking


@dataclass
class ArxivPaper:
    """Metadata and content for a fetched ArXiv paper."""
    paper_id: str
    title: str = ""
    authors: str = ""
    abstract: str = ""
    categories: str = ""
    tex_content: str = ""
    source_url: str = ""

    def __post_init__(self):
        if not self.source_url and self.paper_id:
            self.source_url = f"http://arxiv.org/abs/{self.paper_id}"


class ArxivTexProvider:
    """Fetch recent math papers from ArXiv and extract LaTeX source.

    Maintains a queue of paper IDs and a set of seen IDs to prevent repeats.
    Supports domain-specific queries for targeted mining and a general query
    for cross-pollination.
    """

    def __init__(self, query: str = GENERAL_QUERY, batch_size: int = DEFAULT_BATCH_SIZE,
                 rate_limit: float = DEFAULT_RATE_LIMIT,
                 max_paper_chars: int = DEFAULT_MAX_PAPER_CHARS):
        self.query = query
        self.batch_size = batch_size
        self.rate_limit = rate_limit
        self.max_paper_chars = max_paper_chars
        self.start_index = 0
        self.paper_queue: List[ArxivPaper] = []
        self.seen_ids: set = set()

        self.base_api_url = 'http://export.arxiv.org/api/query?'
        self.namespace = {'atom': 'http://www.w3.org/2005/Atom'}

    def _fetch_next_batch(self) -> List[ArxivPaper]:
        """Pull the next batch of paper metadata from the ArXiv API."""
        params = {
            'search_query': self.query,
            'sortBy': 'submittedDate',
            'sortOrder': 'descending',
            'start': self.start_index,
            'max_results': self.batch_size,
        }
        url = self.base_api_url + urllib.parse.urlencode(params, safe=':"')

        papers = []
        try:
            for attempt in range(3):
                try:
                    response = urllib.request.urlopen(url, timeout=60)
                    xml_data = response.read()
                    root = ET.fromstring(xml_data)
                    break
                except Exception as fetch_err:
                    if attempt < 2:
                        time.sleep(5 * (attempt + 1))
                        continue
                    raise fetch_err

            for entry in root.findall('atom:entry', self.namespace):
                paper_id = entry.find('atom:id', self.namespace).text.split('/abs/')[-1]

                if paper_id in self.seen_ids:
                    continue

                title = ""
                title_elem = entry.find('atom:title', self.namespace)
                if title_elem is not None and title_elem.text:
                    title = " ".join(title_elem.text.split())

                authors_list = []
                for author in entry.findall('atom:author', self.namespace):
                    name = author.find('atom:name', self.namespace)
                    if name is not None and name.text:
                        authors_list.append(name.text)
                authors = ", ".join(authors_list[:5])

                abstract = ""
                summary = entry.find('atom:summary', self.namespace)
                if summary is not None and summary.text:
                    abstract = " ".join(summary.text.split())[:1000]

                categories = ""
                for cat in entry.findall('atom:category', self.namespace):
                    term = cat.get('term', '')
                    if term:
                        categories += term + " "

                paper = ArxivPaper(
                    paper_id=paper_id,
                    title=title,
                    authors=authors,
                    abstract=abstract,
                    categories=categories.strip(),
                    source_url=f"http://arxiv.org/abs/{paper_id}",
                )
                papers.append(paper)
                self.seen_ids.add(paper_id)

            self.start_index += self.batch_size
        except Exception as e:
            print(f"[ArXiv] Error fetching metadata batch: {e}")

        return papers

    def _download_and_extract_tex(self, paper_id: str) -> Optional[str]:
        """Download the e-print and extract .tex content."""
        eprint_url = f'http://export.arxiv.org/e-print/{paper_id}'
        req = urllib.request.Request(eprint_url, headers={
            'User-Agent': 'Aether-Research-Engine/3.0 (mailto:aether@mathresearch.org)',
        })

        try:
            response = urllib.request.urlopen(req, timeout=60)
            data = response.read()
            tex_content = []
            main_file = None  # Track the main .tex file

            # Attempt 1: Try reading as a tarball (standard for multi-file submissions)
            try:
                with tarfile.open(fileobj=io.BytesIO(data), mode='r:gz') as tar:
                    tex_files = []
                    for member in tar.getmembers():
                        if member.name.endswith('.tex'):
                            f = tar.extractfile(member)
                            if f:
                                content = f.read().decode('utf-8', errors='ignore')
                                # Identify main file by \documentclass
                                if r'\documentclass' in content:
                                    main_file = content
                                else:
                                    tex_files.append((member.name, content))
                    # If we found a main file, put it first
                    if main_file:
                        tex_content = [main_file] + [c for _, c in tex_files]
                    elif tex_files:
                        # No \documentclass found, use all files in order
                        tex_content = [c for _, c in tex_files]
            except tarfile.ReadError:
                # Attempt 2: Single gzipped .tex file
                try:
                    with gzip.open(io.BytesIO(data), 'rt', encoding='utf-8', errors='ignore') as f:
                        tex_content.append(f.read())
                except OSError:
                    # Not a valid tarball or gzip — sometimes PDFs are returned
                    return None

            if tex_content:
                combined = "\n\n% --- NEXT TEX FILE ---\n\n".join(tex_content)
                # Structural extraction: prioritize theorem/proof sections
                combined = self._extract_theorem_rich_content(combined)
                if len(combined) > self.max_paper_chars:
                    combined = combined[:self.max_paper_chars] + "\n\n[... truncated for prompt budget ...]"
                return combined
            return None

        except urllib.error.HTTPError:
            return None
        except Exception as e:
            print(f"[ArXiv] Error extracting {paper_id}: {e}")
            return None

    @staticmethod
    def _extract_theorem_rich_content(tex: str) -> str:
        """Extract structurally important content from LaTeX source.

        Prioritizes: abstract, theorems, lemmas, conjectures, proofs.
        Removes: bibliographies, appendices, acknowledgments, figure environments.
        Keeps: section headers and surrounding context.
        """
        import re

        # Remove bibliography entirely
        tex = re.sub(r'\\bibliography\{[^}]*\}', '', tex)
        tex = re.sub(r'\\bibliographystyle\{[^}]*\}', '', tex)
        tex = re.sub(r'\\begin\{thebibliography\}.*?\\end\{thebibliography\}', '', tex, flags=re.DOTALL)

        # Remove appendices (usually surveys or supplementary material)
        tex = re.sub(r'\\appendix.*?(?=\\section|\\subsection|\\end\{document\}|$)', '', tex, flags=re.DOTALL)

        # Remove figure and table environments (visual content, not mathematical)
        tex = re.sub(r'\\begin\{figure\}.*?\\end\{figure\}', '', tex, flags=re.DOTALL)
        tex = re.sub(r'\\begin\{table\}.*?\\end\{table\}', '', tex, flags=re.DOTALL)
        tex = re.sub(r'\\begin\{tikzpicture\}.*?\\end\{tikzpicture\}', '', tex, flags=re.DOTALL)

        # Remove acknowledgment sections
        tex = re.sub(r'\\section\*?\{Acknowledgment.*?\}(.*?)(?=\\section|$)', '', tex, flags=re.DOTALL | re.IGNORECASE)

        # Extract the abstract explicitly (it's the most important summary)
        abstract_match = re.search(r'\\begin\{abstract\}(.*?)\\end\{abstract\}', tex, re.DOTALL)
        abstract_text = abstract_match.group(1).strip() if abstract_match else ""

        # Scan for custom theorem/definition environments
        custom_envs = set()
        for env_match in re.finditer(r'\\newtheorem\*?\{(\w+)\}', tex):
            custom_envs.add(env_match.group(1))
        for env_match in re.finditer(r'\\declaretheorem(?:\[[^\]]*\])?\{(\w+)\}', tex):
            custom_envs.add(env_match.group(1))

        # Standard environments + custom ones
        std_envs = {"theorem", "lemma", "proposition", "corollary", "conjecture", "definition", "remark", "claim", "thm", "lem", "prop", "cor", "defn", "proof", "pf"}
        all_envs = std_envs.union(custom_envs)

        # Escape for regex
        math_envs = r'(?:' + '|'.join(re.escape(e) for e in all_envs) + r')'

        # Extract sections that contain theorem-like environments
        sections = re.split(r'\\section\{', tex)
        theorem_sections = []
        for section in sections[1:]:  # Skip pre-section content
            if re.search(r'\\begin\{' + math_envs + r'}', section, re.IGNORECASE):
                theorem_sections.append('\\section{' + section)

        # Also extract any standalone theorems not in a section
        standalone_theorems = re.findall(
            r'(\\begin\{' + math_envs + r'}.*?\\end\{' + math_envs + r'})',
            tex, re.DOTALL | re.IGNORECASE
        )

        # Build result: abstract + theorem sections + standalone theorems
        parts = []
        if abstract_text:
            parts.append(f"% === ABSTRACT ===\n{abstract_text}")
        if theorem_sections:
            parts.append("% === THEOREM-RICH SECTIONS ===\n" + "\n\n".join(theorem_sections))
        if standalone_theorems and not theorem_sections:
            parts.append("% === KEY THEOREMS ===\n" + "\n\n".join(standalone_theorems))

        result = "\n\n".join(parts) if parts else tex

        # Clean up excessive whitespace
        result = re.sub(r'\n{3,}', '\n\n', result)
        return result

    def _score_paper_relevance(self, paper: ArxivPaper, keywords: Optional[List[str]] = None) -> float:
        """Compute a relevance score for a paper based on its abstract, title, and categories.

        Prioritizes papers with high mathematical content and keyword matches.
        """
        score = 0.0

        # 1. Category check
        cats = paper.categories.lower()
        if "math.nt" in cats or "math.co" in cats or "math.ra" in cats or "math.ac" in cats or "math.ag" in cats:
            score += 2.0
        if "cs.lo" in cats:
            score += 3.0
        elif "cs.cr" in cats or "cs.lg" in cats or "cs.cc" in cats:
            score += 1.0

        # 2. Mathematical term density in abstract and title
        math_terms = [
            "theorem", "lemma", "corollary", "proposition", "definition", "conjecture",
            "proof", "ring", "semiring", "group", "lattice", "poset", "category", "functor",
            "homotopy", "cohomology", "sheaf", "manifold", "metric space", "topology",
            "inequality", "bounds", "continuous", "differentiable", "isomorphism",
            "morphism", "ideal", "module", "field", "variety", "algebra"
        ]

        text = (paper.title + " " + paper.abstract).lower()
        for term in math_terms:
            if term in text:
                score += 0.5
                score += 0.1 * text.count(term)

        # 3. Custom/Dynamic keywords if provided
        if keywords:
            for kw in keywords:
                kw_lower = kw.lower()
                if kw_lower in text:
                    score += 3.0
                    score += 0.5 * text.count(kw_lower)

        return score

    def get_next_paper(self, keywords: Optional[List[str]] = None) -> Optional[ArxivPaper]:
        """Return the next unseen paper with LaTeX content, ranked by relevance.

        Fetches metadata batches as needed, ranks them by keyword and math density
        relevance, downloads source for the highest-ranked paper first, and returns
        an ArxivPaper with content filled in. Returns None if no more
        papers are available.
        """
        attempts = 0
        while attempts < 10:
            if not self.paper_queue:
                new_papers = self._fetch_next_batch()
                if not new_papers:
                    return None

                # Rank new papers by relevance
                scored_papers = []
                for p in new_papers:
                    score = self._score_paper_relevance(p, keywords)
                    scored_papers.append((score, p))

                # Sort descending by score
                scored_papers.sort(key=lambda x: x[0], reverse=True)

                self.paper_queue.extend([p for _, p in scored_papers])

            paper = self.paper_queue.pop(0)
            tex = self._download_and_extract_tex(paper.paper_id)
            if tex:
                paper.tex_content = tex
                time.sleep(self.rate_limit)  # Be nice to ArXiv servers
                return paper

            # Source not available, try next paper
            attempts += 1
            time.sleep(1)  # Brief pause before retrying

        return None

    def set_query(self, query: str) -> None:
        """Change the search query and reset the batch counter."""
        self.query = query
        self.start_index = 0
        self.paper_queue = []

    def set_domain_query(self, domain: str) -> None:
        """Set query to the domain-specific ArXiv query, or general if unknown."""
        self.set_query(DOMAIN_QUERIES.get(domain, GENERAL_QUERIES[0]))

    def set_general_query(self, cycle: int = 0) -> None:
        """Set query to a rotating general cross-pollination query."""
        query = GENERAL_QUERIES[cycle % len(GENERAL_QUERIES)]
        self.set_query(query)


if __name__ == "__main__":
    provider = ArxivTexProvider()

    print("Fetching first valid paper source...")
    paper = provider.get_next_paper()
    if paper:
        print(f"Title: {paper.title}")
        print(f"Authors: {paper.authors}")
        print(f"ArXiv ID: {paper.paper_id}")
        print(f"Categories: {paper.categories}")
        print(f"Content length: {len(paper.tex_content)} chars")
        print(f"Abstract: {paper.abstract[:300]}...")
        print(f"\nFirst 500 chars of LaTeX:\n{paper.tex_content[:500]}")
    else:
        print("No papers found.")