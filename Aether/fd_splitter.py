"""Section-aware future-direction splitter. Ported from validated prototype v2b."""
import re
from typing import List, Tuple, Optional

# Domain keyword table (same as _infer_domains, lines 6-21 of prototype)
DOMAIN_KEYWORDS = {
    "Pythagorean": ["diophantine", "goldbach", "riemann", "zeta", "perfect number",
                     "collatz", "twin prime", "modular form", "euler-mascheroni",
                     "fermat", "sieve", "lehmer", "beal"],
    "NumberTheory": ["number theory", "prime", "coprime", "divisibility", "totient",
                      "congruence", "legendre", "carmichael", "pseudoprime"],
    "Algebra": ["algebra", "ring", "group", "field", "galois", "module",
                "representation", "homomorphism", "ideal", "jacobian", "quadratic form",
                "algebraic", "differentiable", "variational", "integral", "banach",
                "hilbert space", "functional analysis"],
    "Combinatorics": ["combinatorial", "extremal", "ramsey", "graph coloring",
                       "hadamard", "frankl", "union-closed", "erdos", "partition",
                       "matroid", "finset", "graph", "bipartite", "poset", "catalan"],
    "Geometry": ["geometry", "geometric", "curve", "surface", "manifold", "projective",
                 "affine", "convex", "kakeya", "algebraic curve", "schubert",
                 "enumerative", "homotopy", "homology", "poincaré", "knot",
                 "fundamental group", "covering space", "cohomology", "simplicial",
                 "topological"],
    "Computation": ["turing", "complexity", "circuit", "reversible", "automaton",
                    "p vs np", "algorithm", "computability", "np-hard", "percolation",
                    "random", "stochastic", "probability", "martingale", "ergodic"],
    "Tropical": ["tropical", "min-plus", "semiring", "maslov", "dequantization",
                 "idempotent"],
    "Physics": ["quantum", "feynman", "path integral", "wave", "lorentz",
                "yang-mills", "hamiltonian", "lagrangian", "thermodynamic",
                "navier-stokes", "mass gap", "energy", "spectral", "pde"],
    "Cryptography": ["crypto", "spb", "diffie-hellman", "discrete log", "lattice",
                     "dilithium", "encryption", "post-quantum", "zero-knowledge",
                     "homomorphic", "key exchange", "cipher", "authentication"],
    "EML": ["eml", "exponential-multiplicative", "exp-log", "closure operator"],
    "Bridges": ["bridge", "cross-domain", "unification", "functor", "correspondence",
                "langlands", "category-theoretic"],
    "MachineLearning": ["neural", "learning", "approximation", "deep learning",
                        "generalization", "transformer", "attention", "robustness",
                        "adversarial", "pac-bayes"],
    "Logic": ["logic", "type theory", "homotopy type", "proof", "decidable",
              "constructive", "gödel", "incompleteness", "axiom", "ordinal"],
    "Speculative": ["speculative", "science fiction", "consciousness", "alien",
                    "game of life"],
}

# ── Section-header classification ──
RECAP_STEMS = ("proved", "proven", "established", "settled", "formaliz",
               "survived", "failed", "verdict", "evidence", "barrier",
               "scope", "limitation", "completed", "foundation", "recap",
               "summary", "context", "the law", "hypothesis", "result",
               "added", "what")

DIR_STEMS = ("next", "future", "direction", "open", "extend", "extension",
             "further", "target", "step", "conjecture", "question", "problem",
             "programme", "program", "where to go", "natural", "unsolved",
             "remain", "remains", "remaining", "what remains")

RECAP_LEADINS = (
    "derived from", "everything below", "all results", "what is now",
    "what is currently", "what was", "what has been", "what this cycle",
    "what the cycle", "what this phase", "what the formal", "we proved",
    "we established", "these conjectures are", "the conjectures below",
    "the verified cycle", "the formal results",
    "the single *negative* result", "hypothesis tested",
    "hypothesis (null)", "hypothesis.", "resolved part", "settled part",
    "this one was", "proved:", "proved here", "proved in this cycle",
    "proved during", "the three barriers", "the termination time",
    "the collinear stability", "the condition", "for the family",
    "the engine behind", "the quotient of", "every countable family",
    "with equality",
)

HARD_RECAP_STEMS = ("summary", "recap", "verdict", "established", "settled",
                     "survived", "failed", "scope", "limitation",
                     "this delivery", "what was", "what is", "what survived",
                     "what failed", "obtained", "evidence", "proved")

GENERIC_DIR_HEADERS = ("future directions", "future direction", "next steps",
                        "natural next steps", "open problems",
                        "remaining directions", "further work",
                        "directions for future", "concrete next steps",
                        "next steps and open problems", "what remains",
                        "what's next", "whats next", "what comes next",
                        "where to go from here", "remaining work")


def infer_domains_v2(text: str) -> List[str]:
    """Keyword-count domain scoring. NO ['Bridges'] fallback — returns [] on no match."""
    tl = text.lower()
    scores = []
    for dom, kws in DOMAIN_KEYWORDS.items():
        s = sum(1 for k in kws if k in tl)
        if s > 0:
            scores.append((dom, s))
    scores.sort(key=lambda x: -x[1])
    return [d for d, _ in scores[:2]]


def classify_header(h: str) -> str:
    """Classify a markdown header as 'directions', 'recap', or 'unclassified'."""
    hl = h.lower().strip()
    if any(g in hl for g in GENERIC_DIR_HEADERS):
        return "directions"
    if any(s in hl for s in HARD_RECAP_STEMS):
        return "recap"
    is_dir = any(s in hl for s in DIR_STEMS)
    is_recap = any(s in hl for s in RECAP_STEMS)
    if is_dir and not is_recap:
        return "directions"
    if is_recap and not is_dir:
        return "recap"
    if is_recap and is_dir:
        return ("recap" if any(k in hl for k in
                ("proved", "established", "settled", "survived", "failed"))
                else "directions")
    return "unclassified"


HEAD = re.compile(r'(?m)^(#{1,4})\s+(.+?)\s*$')

def split_sections(text: str) -> List[Tuple]:
    """Split markdown into (level, header, body) sections.
    Leading text before first header becomes ('', '', body)."""
    ms = list(HEAD.finditer(text))
    if not ms:
        return [("", "", text)]
    secs = []
    if ms[0].start() > 0:
        secs.append(("", "", text[:ms[0].start()]))
    for i, m in enumerate(ms):
        lvl, hdr = len(m.group(1)), m.group(2).strip()
        end = ms[i + 1].start() if i + 1 < len(ms) else len(text)
        secs.append((lvl, hdr, text[m.end():end]))
    return secs


NUM_BOLD = re.compile(r'\d+\.\s+\*\*([^*]+?)\*\*\s*')
BULLET = re.compile(r'(?m)^\s*[-•*]\s+')
SUBHEAD = re.compile(r'#{2,4}\s+(.+?)\n(.*?)(?=#{2,4}|\Z)', re.DOTALL)

def extract_items(body: str) -> List[Tuple[str, str]]:
    """Extract (title, description) items from body text.
    Priority: numbered-bold > bullets > subheaders."""
    items = []
    # numbered-bold
    for m in NUM_BOLD.finditer(body):
        title = m.group(1).strip().rstrip('.')
        rem = body[m.end():]
        nx = re.search(r'\n\s*\d+\.\s+\*\*', rem)
        desc = (rem[:nx.start()] if nx else rem).strip()
        if nx is None:
            desc = re.split(r'\n\s*\n', desc, 1)[0] if '\n\n' in desc else desc.split('\n\n')[0] if '\n\n' in desc else desc
        desc = desc.strip()[:3000]
        if len(desc) > 30:
            items.append((title, desc))
    if items:
        return items
    # bullets
    bullets = list(BULLET.finditer(body))
    if bullets:
        for i, b in enumerate(bullets):
            end = bullets[i + 1].start() if i + 1 < len(bullets) else len(body)
            raw = body[b.end():end].strip().split('\n\n')[0].strip()
            if len(raw) > 80:
                t = raw[:200].rstrip() + ("..." if len(raw) > 200 else "")
                items.append((t, raw[:3000]))
    if items:
        return items
    # subheaders
    for m in SUBHEAD.finditer(body):
        hdr, b = m.group(1).strip(), m.group(2).strip()
        kw_check = (hdr + b).lower()
        if (len(b) > 100 and
                any(k in kw_check for k in
                    ("prove", "conjecture", "extend", "formalize", "show",
                     "establish", "theorem", "open", "future"))):
            items.append((hdr[:200], b[:3000]))
    return items


def clean_title(t: Optional[str]) -> Optional[str]:
    """Normalize a candidate direction title. Returns None if not usable."""
    if not t:
        return None
    s = t.strip()
    s = re.sub(r'^(?:\*\*|\#+\s*|[-*•])\s*', '', s)
    s = re.sub(r'[\*\#]\s*$', '', s)
    s = re.sub(r'^\d{1,3}\.\s+', '', s)
    m = re.match(r'^(.+?)\*\*\s', s)
    if m and len(m.group(1)) < 90 and not re.search(r'\s+\S{20,}', m.group(1)):
        phrase = m.group(1).strip().rstrip('.:')
        if not re.fullmatch(r'[A-Z][a-zA-Z ]{0,25}', phrase):
            s = m.group(1).strip()
    s = s.replace('**', '')
    if re.fullmatch(r'[\w ()]+:', s):
        return None
    low = s.lower()
    if any(g in low for g in GENERIC_DIR_HEADERS):
        return None
    if low in ("open", "open;", "open:", "next", "next:", "future", "future:",
               "status", "verdict"):
        return None
    if re.match(r'^(?:the\s+)?(?:status|remark|why now|evidence|key insight|'
                r'key idea|note|assumption|notation|verdict|results|summary|'
                r'scope|limitation|this cycle|this research cycle)[\s*:.\?]', low):
        return None
    if any(low.startswith(p) for p in RECAP_LEADINS):
        return None
    if low.startswith(('$', '\\', '`')):
        return None
    if re.search(r'\s[—-]\s*(?:proved|settled|closed|established)\b', s):
        return None
    if re.search(r'\bproved (?:in|during|here|for|to)\b', low):
        return None
    if len(s) < 4:
        return None
    if re.fullmatch(r'\d+\.?\s*', s):
        return None
    if re.fullmatch(r'\([^)]{1,8}\)\s*', s):
        return None
    if re.match(r'^(?:that|which|when|where|whose|then|thus|hence|while|'
                r'and|or|but|with|without)\b', s.lower()):
        return None
    if re.match(r'^[a-z]', s) and len(s.split()) <= 5:
        return None
    return s


def split_directions_from_text(
    mgr,
    text: str,
    source_exp_id: str = "ev",
    source_path: str = "fd_md",
) -> Tuple[int, str]:
    """Section-aware splitter. Returns (directions_added, synthesis_text).

    This is the production port of the validated split_v2b prototype.
    It is the single entry point that add_directions_from_text delegates to.
    """
    from research_memory import FutureDirection
    added = 0
    synthesis_text = ""

    def _maybe_add(fd):
        nonlocal added
        if not mgr._is_quality_direction(fd):
            return False
        q = mgr._compute_quality_score(fd)
        fd.priority_score = min(fd.priority_score, max(0.40, q))
        if fd.title.startswith("Direction "):
            fd.priority_score = min(fd.priority_score, 0.50)
        elif fd.title.startswith("This research cycle") or fd.title.startswith("This cycle"):
            fd.priority_score = min(fd.priority_score, 0.50)
        mgr.add_direction(fd)
        added += 1
        return True

    def _domains(t):
        return infer_domains_v2(t)

    # ── strip recap sections ──
    sections = split_sections(text)
    parts = []
    for lvl, hdr, body in sections:
        if hdr and classify_header(hdr) == "recap":
            continue
        if hdr:
            parts.append('#' * lvl + ' ' + hdr + "\n" + body)
        else:
            parts.append(body)
    text = "\n\n".join(parts)

    # structured ### Direction N:
    structured_pattern = re.compile(
        r'###\s+Direction\s+\d+\s*:\s*(.+?)\n(.*?)(?=\n###\s+Direction\s+\d+|\Z)',
        re.DOTALL,
    )
    for m in structured_pattern.finditer(text):
        title, body = m.group(1).strip(), m.group(2).strip()
        conjecture = mgr._extract_bold_field(body, "Conjecture")
        test = mgr._extract_bold_field(body, "Test")
        impact = mgr._extract_bold_field(body, "Impact")
        proof_strategy = mgr._extract_bold_field(body, "Proof Strategy")
        catalog_refs_raw = mgr._extract_bold_field(body, "Catalog References")
        catalog_references = (
            re.findall(r'`([^`]+)`', catalog_refs_raw) if catalog_refs_raw else []
        )
        desc_parts = [p for p in (conjecture, test, impact) if p]
        description = "\n\n".join(desc_parts) if desc_parts else body[:800]
        fd = FutureDirection(
            id=mgr._next_id(), title=title, description=description,
            source_exp_id=source_exp_id, source_path=source_path,
            domains=_domains(title + " " + description),
            proof_strategy=proof_strategy or "", depth_estimate=3,
            priority_score=0.80, catalog_references=catalog_references,
        )
        _maybe_add(fd)

    # numbered-bold
    if added == 0:
        for m in re.finditer(r'\d+\.\s+\*\*([^*]+?)\*\*\s*', text):
            title = m.group(1).strip().rstrip(".")
            rem = text[m.end():]
            nx = re.search(r'\n\s*\d+\.\s+\*\*', rem)
            desc = (rem[:nx.start()] if nx else rem).strip()[:3000]
            if len(desc) > 30:
                title = clean_title(title)
                if not title:
                    continue
                fd = FutureDirection(
                    id=mgr._next_id(), title=title, description=desc,
                    source_exp_id=source_exp_id, source_path=source_path,
                    domains=_domains(title + " " + desc), depth_estimate=3,
                    priority_score=0.75,
                )
                _maybe_add(fd)

    # plain numbered list
    if added == 0:
        for para in [p.strip() for p in re.split(r'\n\s*\n', text) if p.strip()]:
            if not re.match(r'^\s*\d+\.\s+', para):
                continue
            for item in re.split(r'\s+(?=\d{1,3}\.\s)', para):
                item = item.strip()
                if not re.match(r'^\d+\.', item):
                    continue
                body = re.sub(r'^\d+\.\s*', '', item).strip()
                if len(body) < 30:
                    continue
                sent = re.split(r'(?<=[.!?])\s+', body, maxsplit=1)
                title = clean_title(sent[0])
                if not title:
                    continue
                fd = FutureDirection(
                    id=mgr._next_id(), title=title[:200], description=body[:3000],
                    source_exp_id=source_exp_id, source_path=source_path,
                    domains=_domains(title + " " + body), depth_estimate=3,
                    priority_score=0.70,
                )
                _maybe_add(fd)

    # bullets (BEFORE headers so bullet items win)
    if added == 0:
        for m in re.finditer(
            r'[-•*]\s+(.+?)(?=\n[-•*]|\n\n|\Z)', text, re.DOTALL
        ):
            item = m.group(1).strip()
            if len(item) <= 80:
                continue
            firstline = item.split('\n', 1)[0].lower()
            if any(s in firstline for s in (
                "status.", "remark.", "why now?", "evidence.", "key insight",
                "note.", "assumption.", "notation."
            )):
                continue
            direction_verbs = [
                "prove", "show", "extend", "formalize", "conjecture", "theorem",
                "uniformize", "study", "track", "derive", "construct", "resolve",
                "develop", "generalize", "investigate",
            ]
            if not any(k in item.lower() for k in direction_verbs):
                continue
            title = clean_title(item.split('\n', 1)[0])
            if not title:
                continue
            fd = FutureDirection(
                id=mgr._next_id(), title=title[:200], description=item[:3000],
                source_exp_id=source_exp_id, source_path=source_path,
                domains=_domains(item), depth_estimate=3, priority_score=0.65,
            )
            _maybe_add(fd)

    # markdown headers
    if added == 0:
        for m in re.finditer(
            r'#{2,4}\s+(.+?)\n(.*?)(?=#{2,4}|\Z)', text, re.DOTALL
        ):
            header, body = m.group(1).strip(), m.group(2).strip()
            if classify_header(header) == "recap":
                continue
            if not clean_title(header):
                continue
            kw_check = (header + body).lower()
            direction_kws = [
                "prove", "show", "extend", "formalize", "conjecture", "theorem",
                "establish", "open", "future", "direction",
            ]
            if (len(body) > 100 and
                    any(k in kw_check for k in direction_kws)):
                fd = FutureDirection(
                    id=mgr._next_id(), title=header[:200], description=body[:3000],
                    source_exp_id=source_exp_id, source_path=source_path,
                    domains=_domains(header + " " + body), depth_estimate=3,
                    priority_score=0.7,
                )
                _maybe_add(fd)

    # paragraph fallback
    if added == 0 and len(text) > 80:
        for para in [p.strip() for p in re.split(r'\n\s*\n', text) if p.strip()]:
            if len(para) < 80:
                continue
            sentences = re.split(r'(?<=[.!?])\s+', para, maxsplit=1)
            title = clean_title(sentences[0])
            if not title:
                continue
            fd = FutureDirection(
                id=mgr._next_id(), title=title[:200], description=para[:3000],
                source_exp_id=source_exp_id, source_path=source_path,
                domains=_domains(title + " " + para), depth_estimate=3,
                priority_score=0.65,
            )
            _maybe_add(fd)

    return (added, synthesis_text)
