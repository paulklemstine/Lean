"""
Lineage Extractor — Infers parent→child edges between AETHER research packages
by analyzing future_directions text, domain overlap, and config arc groupings.

Outputs lineage.json to the Packages directory for the Knowledge Graph visualization.
"""

import json
import os
import re
import glob
import yaml
from difflib import SequenceMatcher
from collections import defaultdict

# 12 canonical domains mapped to shapes for the Knowledge Graph
DOMAIN_SHAPES = {
    "Algebra": "tetrahedron",
    "Bridges": "icosahedron",
    "Computation": "cube",
    "Cryptography": "dodecahedron",
    "EML": "octahedron",
    "Geometry": "hexagonal_prism",
    "Logic": "star_of_david",
    "MachineLearning": "sphere_rings",
    "Physics": "diamond",
    "Pythagorean": "triangular_prism",
    "Speculative": "pentagonal_prism",
    "Tropical": "star",
}

CANONICAL_DOMAINS = list(DOMAIN_SHAPES.keys())


def canonicalize_domain(domain_str):
    """Extract canonical domain labels from a freeform domain string.

    Handles formats like:
    - "Bridges (Algebra x ML x Cryptography)"
    - "Algebra / Logic / Computation Bridges"
    - "Algebra-Tropical-Computation"
    Returns a list of canonical domain names.
    """
    if not domain_str:
        return ["Bridges"]

    # Normalize separators
    text = domain_str.replace("×", "x").replace("×", "x")
    # Replace common parenthetical forms: "Bridges (A x B x C)" -> "Bridges A B C"
    text = re.sub(r"[()]", " ", text)
    text = text.replace("/", " ").replace("-", " ").replace("x", " ").replace(",", " ")

    found = []
    text_lower = text.lower()
    for domain in CANONICAL_DOMAINS:
        # Match domain name as a word boundary-ish substring
        # EML is tricky since it's short
        if domain == "EML":
            if "eml" in text_lower:
                found.append(domain)
        elif domain == "MachineLearning":
            if "machine learning" in text_lower or "machinelearning" in text_lower or "ml" in text_lower.split():
                found.append(domain)
        else:
            pattern = domain.lower()
            if pattern in text_lower:
                # Avoid partial matches: "Logic" shouldn't match "Logical"
                # But for simplicity, we accept substring matches since domains are distinctive
                found.append(domain)

    return found if found else ["Bridges"]


def primary_domain(domain_str):
    """Return the single primary domain for a package (first canonical match, or 'Bridges')."""
    domains = canonicalize_domain(domain_str)
    return domains[0]


def extract_concepts_from_future_directions(text):
    """Extract research concept keywords from future_directions markdown text.

    Returns a list of concept strings suitable for matching to other packages.
    """
    if not text:
        return []

    concepts = []

    # Extract theorem names: theorem xxx or lemma xxx (skip common words)
    STOP_THEOREMS = {"follows", "targets", "to", "by", "if", "let", "have", "show", "from"}
    for match in re.finditer(r'(?:theorem|lemma)\s+(\w+)', text):
        name = match.group(1)
        if name not in STOP_THEOREMS and len(name) > 3:
            concepts.append(("theorem", name))

    # Extract section headings (### level) as concept indicators
    for match in re.finditer(r'###\s+\d*\.?\s*(.+)', text):
        heading = match.group(1).strip()
        # Remove markdown bold/italic
        heading = re.sub(r'[*_`]', '', heading)
        # Skip very short or very long headings
        if 10 < len(heading) < 120:
            concepts.append(("heading", heading))

    # Extract "Cross-Domain Connections" or "Cross-Domain Bridges" mentions
    for match in re.finditer(r'\*\*([^*]+)\*\*[^*]*(?:connection|bridge|link|application)', text, re.IGNORECASE):
        phrase = match.group(1).strip()
        if len(phrase) > 3:
            concepts.append(("cross_domain", phrase))

    # Extract theorem targets/statements
    for match in re.finditer(r'(?:Theorem Target|Theorem Statement)\s*:?\s*`?([^`\n]+)`?', text, re.IGNORECASE):
        stmt = match.group(1).strip().rstrip('`')
        if len(stmt) > 5:
            concepts.append(("theorem_stmt", stmt))

    # Extract catalog leverage references
    for match in re.finditer(r'(?:Catalog Leverage|catalog_leverage)\s*:?\s*(.+?)(?:\n|$)', text, re.IGNORECASE):
        refs = match.group(1).strip()
        # Split on commas
        for ref in re.split(r'[,;]', refs):
            ref = ref.strip().strip('`').strip('"\'')
            if ref and len(ref) > 2:
                concepts.append(("catalog_ref", ref))

    return concepts


def compute_edge_score(source_pkg, target_pkg, concepts, all_packages_by_slug, arcs):
    """Compute a score for whether source_pkg's future_directions led to target_pkg.

    Higher scores = more likely lineage connection.
    """
    score = 0.0
    reasons = []

    source_domains = canonicalize_domain(source_pkg.get("domain", ""))
    target_domains = canonicalize_domain(target_pkg.get("domain", ""))

    # Domain overlap: +3 per shared canonical domain
    shared = set(source_domains) & set(target_domains)
    if shared:
        score += 3.0 * len(shared)
        reasons.append(f"domain_overlap:{','.join(shared)}")

    # Cross-domain: if source mentions a domain that target is IN, +2
    source_fd = source_pkg.get("future_directions", "")
    source_fd_lower = source_fd.lower()
    for td in target_domains:
        td_lower = td.lower()
        if td == "EML":
            if "eml" in source_fd_lower:
                score += 2.0
                reasons.append(f"fd_mentions_domain:{td}")
        elif td == "MachineLearning":
            if "machine learning" in source_fd_lower or "machinelearning" in source_fd_lower:
                score += 2.0
                reasons.append(f"fd_mentions_domain:{td}")
        else:
            if td_lower in source_fd_lower:
                score += 2.0
                reasons.append(f"fd_mentions_domain:{td}")

    # Title keyword overlap: fuzzy match between concept headings and target title
    target_title = target_pkg.get("title", "").lower()
    target_title_words = set(re.findall(r'\w+', target_title))

    for ctype, cvalue in concepts:
        if ctype == "heading":
            # Fuzzy match heading to target title
            ratio = SequenceMatcher(None, cvalue.lower(), target_title).ratio()
            if ratio > 0.4:
                score += 2.0 * ratio
                reasons.append(f"heading_match:{cvalue[:40]}")

        elif ctype == "theorem":
            # Exact or fuzzy match theorem name to target title/lean_proofs
            thm_lower = cvalue.lower()
            if thm_lower in target_title:
                score += 2.0
                reasons.append(f"theorem_in_title:{cvalue}")

        elif ctype == "cross_domain":
            # Fuzzy match cross-domain phrase to target title
            ratio = SequenceMatcher(None, cvalue.lower(), target_title).ratio()
            if ratio > 0.35:
                score += 1.5 * ratio
                reasons.append(f"cross_domain_match:{cvalue[:40]}")

        elif ctype == "theorem_stmt":
            # Extract key identifiers from theorem statement
            stmt_words = set(re.findall(r'\w+', cvalue.lower()))
            overlap = len(stmt_words & target_title_words)
            if overlap > 2:
                score += 1.0 * overlap
                reasons.append(f"stmt_overlap:{overlap}")

    # Shared modules: extract function names from code strings or dict keys
    def _get_module_names(pkg):
        mods = pkg.get("modules", {})
        if isinstance(mods, dict):
            alg = mods.get("algorithms", {})
            if isinstance(alg, dict):
                return set(alg.keys())
            if isinstance(alg, str):
                return set(re.findall(r'def\s+(\w+)', alg))
        return set()

    source_modules = _get_module_names(source_pkg)
    target_modules = _get_module_names(target_pkg)
    shared_mods = source_modules & target_modules
    if shared_mods:
        score += 1.0 * len(shared_mods)
        reasons.append(f"shared_modules:{','.join(shared_mods)}")

    # Arc co-membership: if both packages' domains appear in the same arc
    for arc in arcs:
        arc_domains = set(arc.get("seed_domains", []))
        if arc_domains & set(source_domains) and arc_domains & set(target_domains):
            score += 1.5
            reasons.append(f"arc:{arc.get('id', '?')}")
            break  # Count arc bonus once

    # Title keyword overlap with future_directions text
    # If source's future_directions mentions keywords from target's title
    target_title_keywords = set(re.findall(r'\w{4,}', target_title))
    meaningful_keywords = target_title_keywords - {
        'theorem', 'lemma', 'proof', 'via', 'with', 'for', 'from', 'and',
        'the', 'using', 'over', 'under', 'between', 'through', 'based',
        'new', 'generalized', 'extended', 'discovery', 'breakthrough',
    }
    fd_words = set(re.findall(r'\w{4,}', source_fd_lower))
    keyword_overlap = meaningful_keywords & fd_words
    if len(keyword_overlap) >= 3:
        overlap_ratio = len(keyword_overlap) / max(len(meaningful_keywords), 1)
        score += 3.0 * overlap_ratio
        reasons.append(f"title_fd_overlap:{len(keyword_overlap)}/{len(meaningful_keywords)}")

    return score, reasons


def load_config_arcs(config_path):
    """Load research arcs from config.yaml."""
    if not os.path.exists(config_path):
        return []
    with open(config_path, 'r') as f:
        config = yaml.safe_load(f)
    return config.get("research", {}).get("arcs", [])


def deduplicate_transitive_edges(edges, min_strength=0.4):
    """Remove weak transitive edges: if A→B and B→C exist, remove A→C
    only if A→C is weaker than both A→B and B→C.

    Also remove edges below min_strength threshold.
    """
    # Build adjacency with strengths for transitive check
    by_source = defaultdict(dict)
    for e in edges:
        by_source[e["source"]][e["target"]] = e["strength"]

    # Build edge lookup for strength comparison
    edge_strength = {}
    for e in edges:
        edge_strength[(e["source"], e["target"])] = e["strength"]

    filtered = []
    for e in edges:
        src, tgt, strength = e["source"], e["target"], e["strength"]

        # Skip edges below minimum strength
        if strength < min_strength:
            continue

        # Check if this is a transitive edge with a stronger 2-hop path
        is_weak_transitive = False
        for mid in by_source.get(src, {}):
            if mid == tgt:
                continue
            if tgt in by_source.get(mid, {}):
                ab_strength = by_source[src][mid]
                bc_strength = by_source[mid][tgt]
                # If both intermediate edges are stronger, skip this one
                if ab_strength > strength and bc_strength > strength:
                    is_weak_transitive = True
                    break

        if not is_weak_transitive:
            filtered.append(e)

    return filtered


def mulberry32(seed):
    """Seeded PRNG for deterministic hue generation."""
    def inner():
        nonlocal seed
        seed = (seed + 0x6D2B79F5) & 0xFFFFFFFF
        t = seed ^ (seed >> 15)
        t = (t * (t | 1)) & 0xFFFFFFFF
        t = (t ^ (t + 0x3FB52453)) & 0xFFFFFFFF
        t = (t ^ (t >> 13)) & 0xFFFFFFFF
        return t / 4294967296
    return inner


def slug_to_hue(slug):
    """Generate a deterministic hue (0-360) from a package slug."""
    rng = mulberry32(hash(slug))
    return int(rng() * 360)


def extract_edge_label(reasons, source_title="", target_title=""):
    """Extract a meaningful label from scoring reasons.

    Prefers specific concept matches over generic domain overlap.
    """
    STOP_WORDS = {"for", "in", "to", "of", "via", "and", "the", "a", "an", "is", "on", "by", "with", "from"}

    # Prefer heading matches (most specific)
    for r in reasons:
        if r.startswith("heading_match:"):
            label = r.split(":", 1)[1].strip()
            label = re.sub(r'^\d+\.\s*', '', label)
            if len(label) > 5 and label.lower() not in STOP_WORDS:
                return label[:60]

    # Then theorem matches
    for r in reasons:
        if r.startswith("theorem_in_title:"):
            return r.split(":", 1)[1][:60]

    # Then cross-domain concepts
    for r in reasons:
        if r.startswith("cross_domain_match:"):
            return r.split(":", 1)[1][:60]

    # Then title-fd overlap — try to extract a meaningful phrase from target title
    for r in reasons:
        if r.startswith("title_fd_overlap:"):
            # Use first meaningful words from target title
            words = re.findall(r'[A-Z][a-z]+(?:\s+[A-Z][a-z]+)*', target_title)
            if words:
                return words[0][:60]
            return ""

    # Then domain overlap — list the shared domains
    for r in reasons:
        if r.startswith("domain_overlap:"):
            domains = r.split(":", 1)[1]
            return f"{domains} bridge"

    # Then arc matches
    for r in reasons:
        if r.startswith("arc:"):
            return ""

    if reasons:
        label = reasons[0][:60]
        if label.lower() in STOP_WORDS:
            return ""
        return label
    return ""


def build_lineage(packages_dir, config_path=None):
    """Build lineage graph from package JSON files.

    Returns a dict with 'nodes' and 'edges' lists.
    """
    if config_path is None:
        config_path = os.path.join(os.path.dirname(__file__), "config.yaml")

    arcs = load_config_arcs(config_path)

    # Load all packages
    json_files = sorted(glob.glob(os.path.join(packages_dir, "*.json")))
    packages = {}
    for f in json_files:
        slug = os.path.basename(f).replace('.json', '')
        # Skip non-package files
        if slug in ('index', 'package', 'lineage'):
            continue
        # Skip files that don't have a 'title' field (not real packages)
        try:
            with open(f, 'r', encoding='utf-8') as fh:
                data = json.load(fh)
            if not isinstance(data, dict) or 'title' not in data:
                continue
            packages[slug] = data
        except Exception as e:
            print(f"Warning: failed to load {f}: {e}")
        try:
            with open(f, 'r', encoding='utf-8') as fh:
                data = json.load(fh)
            packages[slug] = data
        except Exception as e:
            print(f"Warning: failed to load {f}: {e}")

    # Sort packages by date for temporal ordering
    sorted_slugs = sorted(
        packages.keys(),
        key=lambda s: packages[s].get("date", "9999")
    )

    # Build nodes
    nodes = []
    for slug in sorted_slugs:
        pkg = packages[slug]
        domain_str = pkg.get("domain", "Bridges")
        primary = primary_domain(domain_str)
        shape = DOMAIN_SHAPES.get(primary, "icosahedron")
        nodes.append({
            "id": slug,
            "title": pkg.get("title", slug),
            "domain": domain_str,
            "primary_domain": primary,
            "shape": shape,
            "date": pkg.get("date", ""),
            "hue": slug_to_hue(slug),
        })

    # Build edges from future_directions analysis
    edges = []
    for i, source_slug in enumerate(sorted_slugs):
        source_pkg = packages[source_slug]
        fd_text = source_pkg.get("future_directions", "")
        if not fd_text:
            continue

        concepts = extract_concepts_from_future_directions(fd_text)

        for target_slug in sorted_slugs:
            if target_slug == source_slug:
                continue
            target_pkg = packages[target_slug]

            # Temporal ordering: prefer older→newer, but allow same-day edges
            # when there's a strong conceptual signal
            source_date = source_pkg.get("date", "9999")
            target_date = target_pkg.get("date", "9999")
            same_day = source_date[:10] == target_date[:10] and source_date[:10] != "9999"
            if source_date > target_date:
                # Source is newer — no edge possible
                continue
            elif source_date == target_date or same_day:
                # Same day — edges need higher score threshold to avoid noise
                pass

            score, reasons = compute_edge_score(
                source_pkg, target_pkg, concepts, packages, arcs
            )

            # Same-day edges need a higher threshold to avoid spurious connections
            min_score_threshold = 5.0 if same_day else 3.0
            if score >= min_score_threshold:
                edges.append({
                    "source": source_slug,
                    "target": target_slug,
                    "strength": min(score / 10.0, 1.0),
                    "label": extract_edge_label(reasons, source_pkg.get("title", ""), target_pkg.get("title", "")),
                    "score": round(score, 2),
                    "same_day": same_day,
                })

    # Limit outgoing edges per node to avoid hairballs
    # Keep top 3 outgoing edges per source
    from collections import Counter
    outgoing_counts = Counter()
    filtered_edges = []
    edges.sort(key=lambda e: e["score"], reverse=True)
    for e in edges:
        key = e["source"]
        if outgoing_counts[key] < 3:
            filtered_edges.append(e)
            outgoing_counts[key] += 1
    edges = filtered_edges

    # Deduplicate transitive edges
    edges = deduplicate_transitive_edges(edges, min_strength=0.3)

    # Sort edges by score descending
    edges.sort(key=lambda e: e["score"], reverse=True)

    # Limit total edges to keep visualization clean (max 80 edges)
    if len(edges) > 80:
        edges = edges[:80]

    # Normalize strength relative to the actual score distribution
    if edges:
        scores = [e["score"] for e in edges]
        min_s = min(scores)
        max_s = max(scores)
        range_s = max_s - min_s if max_s > min_s else 1.0
        for e in edges:
            # Map to 0.3..1.0 range so even weak edges are visible
            e["strength"] = 0.3 + 0.7 * ((e["score"] - min_s) / range_s)

    # Clean up internal fields from output
    for e in edges:
        e.pop("score", None)
        e.pop("same_day", None)

    print(f"Built lineage: {len(nodes)} nodes, {len(edges)} edges")
    return {"nodes": nodes, "edges": edges}


def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    config_path = os.path.join(script_dir, "config.yaml")
    packages_dir = os.path.join(
        os.path.dirname(script_dir),
        "Catalog", "Applications", "Packages"
    )

    lineage = build_lineage(packages_dir, config_path)

    output_path = os.path.join(packages_dir, "lineage.json")
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(lineage, f, indent=2, ensure_ascii=False)

    print(f"Wrote lineage.json to {output_path}")
    print(f"  Nodes: {len(lineage['nodes'])}")
    print(f"  Edges: {len(lineage['edges'])}")

    # Print edge summary
    for e in lineage["edges"][:20]:
        print(f"  {e['source']} → {e['target']} (strength={e['strength']:.2f}, label={e['label']})")


if __name__ == "__main__":
    main()