"""
Lineage Extractor — Infers parent→child edges between AETHER research packages
by analyzing future_directions text, domain overlap, and config arc groupings.

Outputs lineage.json to the Packages directory for the Knowledge Graph visualization.
"""

import json
import os
import re
import glob
from difflib import SequenceMatcher
from collections import defaultdict, Counter
from pathlib import Path

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
    """Return the single primary domain for a package.

    Picks the least-common domain across all packages for visual variety,
    falling back to the first match if no frequency data is available.
    """
    domains = canonicalize_domain(domain_str)
    if not domains:
        return "Bridges"
    # Prefer the least common domain for visual variety
    # This is computed once during build_lineage and passed via global
    if hasattr(primary_domain, 'domain_counts'):
        return min(domains, key=lambda d: primary_domain.domain_counts.get(d, 0))
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


def build_domain_bridges(packages_by_slug):
    """Compute domain-level bridges between domain clusters.

    A bridge exists between two domains when packages span both domains.
    Returns a list of {domain_a, domain_b, package_count, strength} dicts,
    sorted by strength descending.
    """
    pair_counts = Counter()
    total_packages = len(packages_by_slug)

    for slug, pkg in packages_by_slug.items():
        domains = canonicalize_domain(pkg.get("domain", ""))
        for i, d1 in enumerate(domains):
            for d2 in domains[i + 1:]:
                pair = tuple(sorted([d1, d2]))
                pair_counts[pair] += 1

    bridges = []
    for (d1, d2), count in pair_counts.items():
        bridges.append({
            "domain_a": d1,
            "domain_b": d2,
            "package_count": count,
            "strength": min(0.3 + 0.2 * count, 1.0),
        })

    bridges.sort(key=lambda b: b["strength"], reverse=True)
    return bridges


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


def build_lineage(packages_dir):
    """Build lineage graph from package JSON files.

    Returns a dict with 'nodes', 'edges', and 'domain_bridges' lists.
    """

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

    # Sort packages by date for temporal ordering
    sorted_slugs = sorted(
        packages.keys(),
        key=lambda s: packages[s].get("date", "9999")
    )

    # Compute domain frequency counts for primary_domain variety
    domain_counter = Counter()
    for slug in sorted_slugs:
        for d in canonicalize_domain(packages[slug].get("domain", "")):
            domain_counter[d] += 1
    primary_domain.domain_counts = dict(domain_counter)

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

    # ── Phase 1: Provenance-based edges (factual, from source_exp_ids) ──
    provenance_edges = []
    provenance_pairs = set()

    # Load exp_id_map for provenance lookups
    exp_id_map = {}
    workspace_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".aether_workspace")
    map_path = os.path.join(workspace_dir, "exp_id_map.json")
    if os.path.exists(map_path):
        try:
            with open(map_path, 'r', encoding='utf-8') as mf:
                exp_id_map = json.load(mf)
        except Exception:
            exp_id_map = {}

    # Also build a reverse map: exp_id → slug from package data
    pkg_exp_ids = {}  # exp_id → slug
    for slug, pkg in packages.items():
        eid = pkg.get("exp_id", "")
        if eid:
            pkg_exp_ids[eid] = slug

    for slug, pkg in packages.items():
        source_ids = pkg.get("source_exp_ids", [])
        for src_exp_id in source_ids:
            # Skip "seed" source — it's a virtual root, not a real package
            if src_exp_id == "seed":
                continue
            # Find parent slug: first check exp_id_map, then pkg_exp_ids
            parent_slug = None
            parent_filename = exp_id_map.get(src_exp_id, "")
            if parent_filename:
                parent_slug = parent_filename.replace('.json', '')
            if not parent_slug or parent_slug not in packages:
                parent_slug = pkg_exp_ids.get(src_exp_id)
            if parent_slug and parent_slug in packages and parent_slug != slug:
                pair = (parent_slug, slug)
                if pair not in provenance_pairs:
                    provenance_pairs.add(pair)
                    # Try to extract a meaningful label
                    parent_pkg = packages[parent_slug]
                    label = "inspired by"
                    fd_text = parent_pkg.get("future_directions", "")
                    tgt_title = pkg.get("title", "").lower()
                    if fd_text and tgt_title:
                        concepts = extract_concepts_from_future_directions(fd_text)
                        reasons = []
                        for ctype, cvalue in concepts:
                            if ctype == "heading":
                                ratio = SequenceMatcher(None, cvalue.lower(), tgt_title).ratio()
                                if ratio > 0.3:
                                    reasons.append(f"heading_match:{cvalue}")
                            elif ctype == "theorem":
                                if cvalue.lower() in tgt_title:
                                    reasons.append(f"theorem_in_title:{cvalue}")
                        if reasons:
                            label = extract_edge_label(reasons, parent_pkg.get("title", ""), pkg.get("title", ""))
                    provenance_edges.append({
                        "source": parent_slug,
                        "target": slug,
                        "strength": 1.0,
                        "label": label,
                        "type": "provenance",
                    })

    # ── Phase 1b: Provenance from FutureDirectionsManager ──
    # Directions consumed by one cycle but generated by another create real provenance edges
    try:
        from research_memory import FutureDirectionsManager
        fd_manager = FutureDirectionsManager(Path(workspace_dir))
        for d in fd_manager._directions:
            if not d.consumed_by_exp_id:
                continue
            child_exp_id = d.consumed_by_exp_id
            child_filename = exp_id_map.get(child_exp_id, "")
            if not child_filename:
                continue
            child_slug = child_filename.replace('.json', '')
            if child_slug not in packages:
                continue
            # Find parent: source_exp_id -> filename, or source_path -> slug
            parent_slug = None
            if d.source_exp_id and d.source_exp_id not in ('unknown', 'seed'):
                parent_filename = exp_id_map.get(d.source_exp_id, "")
                if parent_filename:
                    parent_slug = parent_filename.replace('.json', '')
            if not parent_slug and d.source_path.startswith('json:'):
                parent_slug = d.source_path[5:].replace('.json', '')
            if not parent_slug or parent_slug not in packages or parent_slug == child_slug:
                continue
            pair = (parent_slug, child_slug)
            if pair in provenance_pairs:
                continue
            provenance_pairs.add(pair)
            label = d.title if d.title and d.title != d.id else "inspired by"
            if len(label) > 60:
                label = label[:57] + "..."
            provenance_edges.append({
                "source": parent_slug,
                "target": child_slug,
                "strength": 1.0,
                "label": label,
                "type": "provenance",
            })
    except Exception as e:
        print(f"Warning: could not load FutureDirectionsManager for provenance: {e}")

    print(f"Provenance edges: {len(provenance_edges)}")

    # Remove edges that reference non-existent packages (ghost nodes)
    real_slugs = {n["id"] for n in nodes}
    before = len(provenance_edges)
    edges = [e for e in provenance_edges if e["source"] in real_slugs and e["target"] in real_slugs]
    if before != len(edges):
        print(f"Removed {before - len(edges)} edges with ghost nodes")

    # ── Domain bridges: cross-domain connections for visualization ──
    domain_bridges = build_domain_bridges(packages)
    print(f"Domain bridges: {len(domain_bridges)}")

    print(f"Built lineage: {len(nodes)} nodes, {len(edges)} edges, {len(domain_bridges)} bridges")
    return {"nodes": nodes, "edges": edges, "domain_bridges": domain_bridges}


def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    packages_dir = os.path.join(
        os.path.dirname(script_dir),
        "Packages"
    )

    lineage = build_lineage(packages_dir)

    output_path = os.path.join(packages_dir, "lineage.json")
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(lineage, f, indent=2, ensure_ascii=False)

    print(f"Wrote lineage.json to {output_path}")
    print(f"  Nodes: {len(lineage['nodes'])}")
    print(f"  Edges: {len(lineage['edges'])}")
    print(f"  Domain bridges: {len(lineage['domain_bridges'])}")

    # Print bridge summary
    for b in lineage["domain_bridges"][:10]:
        print(f"  {b['domain_a']} ↔ {b['domain_b']} (packages={b['package_count']}, strength={b['strength']:.2f})")


if __name__ == "__main__":
    main()