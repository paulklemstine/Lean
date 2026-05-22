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


# Domain-specific ArXiv queries mapped to Aether research domains
DOMAIN_QUERIES = {
    "Pythagorean": 'cat:math.NT AND all:"Pythagorean"',
    "Tropical": 'cat:math.CO OR all:"tropical semiring" OR all:"min-plus"',
    "Cryptography": 'cat:cs.CR AND all:"lattice" OR all:"post-quantum"',
    "Algebra": 'cat:math.RA OR all:"semiring" OR all:"idempotent"',
    "EML": 'all:"exponential" AND all:"logarithmic" AND all:"activation"',
    "MachineLearning": 'cat:cs.LG AND all:"certified robustness" OR all:"neural network verification"',
    "Physics": 'cat:math-ph OR all:"Hamiltonian" OR all:"Lagrangian"',
    "Logic": 'cat:cs.LO AND all:"formal verification" OR all:"proof assistant"',
    "Computation": 'cat:cs.CC AND all:"complexity" OR all:"computability"',
    "Bridges": 'all:"interdisciplinary" OR all:"cross-domain"',
    "Speculative": 'all:"speculative" OR all:"hypothetical"',
    "Geometry": 'cat:math.AG OR all:"manifold" OR all:"algebraic geometry"',
}

# General query for cross-pollination (used on even cycles)
GENERAL_QUERY = 'cat:math.NT OR cat:math.CO OR cat:cs.CR OR cat:cs.LG OR cat:math.RA'

# Default config values
DEFAULT_RATE_LIMIT = 3  # seconds between downloads
DEFAULT_MAX_PAPER_CHARS = 8000  # truncate paper content for prompt budget
DEFAULT_BATCH_SIZE = 5


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
            response = urllib.request.urlopen(url, timeout=30)
            xml_data = response.read()
            root = ET.fromstring(xml_data)

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

            # Attempt 1: Try reading as a tarball (standard for multi-file submissions)
            try:
                with tarfile.open(fileobj=io.BytesIO(data), mode='r:gz') as tar:
                    for member in tar.getmembers():
                        if member.name.endswith('.tex'):
                            f = tar.extractfile(member)
                            if f:
                                tex_content.append(f.read().decode('utf-8', errors='ignore'))
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
                # Truncate for prompt budget
                if len(combined) > self.max_paper_chars:
                    combined = combined[:self.max_paper_chars] + "\n\n[... truncated for prompt budget ...]"
                return combined
            return None

        except urllib.error.HTTPError:
            return None
        except Exception as e:
            print(f"[ArXiv] Error extracting {paper_id}: {e}")
            return None

    def get_next_paper(self) -> Optional[ArxivPaper]:
        """Return the next unseen paper with LaTeX content.

        Fetches metadata batches as needed, downloads source, and returns
        an ArxivPaper with content filled in. Returns None if no more
        papers are available.
        """
        attempts = 0
        while attempts < 10:
            if not self.paper_queue:
                new_papers = self._fetch_next_batch()
                self.paper_queue.extend(new_papers)
                if not self.paper_queue:
                    return None

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
        self.set_query(DOMAIN_QUERIES.get(domain, GENERAL_QUERY))

    def set_general_query(self) -> None:
        """Set query to the general cross-pollination query."""
        self.set_query(GENERAL_QUERY)


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