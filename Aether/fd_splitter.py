"""Section-aware future-direction splitter. Ported from validated prototype v2b."""
import re
from typing import List, Tuple, Optional
from research_memory import FutureDirection

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
        desc = (rem[:nx.start()] if nx else rem).strip()[:3000]
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
