from typing import Callable, Dict, List, Optional, Set, Tuple
from dataclasses import dataclass
from collections import defaultdict
TemporalConstraint = Callable[[int, int], bool]
from algorithms import RevStep, orbit_decomposition, orbit_period, \
    find_novikov_witness, compute_nerode_quotient, quotient_automaton, \
    check_novikov_consistency, temporal_signature
from typing import List, Dict, Tuple
import json
import numpy as np
from typing import Callable, List, Tuple, Set, Dict
TemporalConstraint = Callable[[int, int], bool]
import json
import base64
from pathlib import Path
article = read_file("ARTICLE.md")
research_paper = read_file("RESEARCH_PAPER.md")
future_directions = read_file("FUTURE_DIRECTIONS.md")
lean_proofs = read_file("TemporalFixedPointSemantics.lean")
demo_code = read_file("demo.py")
algorithms_code = read_file("algorithms.py")
applications_code = read_file("applications.py")
diagram_svg = read_file("diagram.svg")
orbits_b64 = read_image_base64("orbits.png")
signatures_b64 = read_image_base64("signatures.png")
nerode_b64 = read_image_base64("nerode_quotient.png")
bounds_b64 = read_image_base64("bounds.png")
package = {
    "title": "Logic-Computation Temporal Fixed-Point Semantics via Reversible Oracle Groupoids and Novikov Consistency",
    "domain": "Bridges (Logic × Computation × Physics × Cryptography)",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {"name": "Reversible Oracle Dynamics Demo", "code": demo_code},
        {"name": "Applications (Quantum/Crypto/ML)", "code": applications_code},
    ],
    "algorithms": [
        {
            "name": "Novikov Witness Search",
            "pseudocode": "FindNovikovWitness(r, φ, n, s, B):\n  current ← s\n  For m = 1..B:\n    current ← r(current)\n    If φ(n+m, current): return m\n  Return FAIL\n  Complexity: O(B) = O(|S|)"
        },
        {
            "name": "Temporal Nerode Quotient",
            "pseudocode": "ComputeNerodeQuotient(r, Φ, H):\n  For each s ∈ S:\n    sig[s] ← [TemporalSignature(r,φ,s,H) for φ ∈ Φ]\n  Group states by identical signatures\n  Complexity: O(|S|·|Φ|·H)\n  Classes ≤ |S|"
        },
        {
            "name": "Orbit Decomposition",
            "pseudocode": "OrbitDecomposition(r):\n  visited ← ∅\n  For s ∈ S \\ visited:\n    Follow orbit until revisit\n    Record orbit\n  Complexity: O(|S|)"
        },
    ],
    "visualizations": [
        {"name": "Orbit Structure", "data": orbits_b64},
        {"name": "Temporal Signatures", "data": signatures_b64},
        {"name": "Nerode Quotient Classes", "data": nerode_b64},
        {"name": "Computational Bounds", "data": bounds_b64},
        {"name": "Architecture Diagram", "data": diagram_svg},
    ],
    "lean_proofs": lean_proofs,
}
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from algorithms import RevStep, orbit_decomposition, compute_nerode_quotient, \
    temporal_signature, check_novikov_consistency
import base64
from io import BytesIO

def orbit_decomposition(r: RevStep) -> List[List[int]]:
    """Decompose the state space into disjoint orbits.

    Complexity: O(|S|) time and space.

    Returns:
        List of orbits, each orbit is a list of states in order.
    """
    visited: Set[int] = set()
    orbits: List[List[int]] = []
    for start in range(r.n):
        if start in visited:
            continue
        orbit = []
        s = start
        while s not in visited:
            visited.add(s)
            orbit.append(s)
            s = r.apply(s)
        orbits.append(orbit)
    return orbits