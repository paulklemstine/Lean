// AUTO-GENERATED FILE. DO NOT EDIT.
// This file bundles all JSON packages so they can be loaded from file:// without CORS issues.

window.PACKAGE_INDEX = [
  {
    "filename": "example_number_theory.json",
    "title": "Harmonic Resonance in the Primes",
    "domain": "Analytic Number Theory",
    "date": "2026-05-10T14:45:33Z"
  },
  {
    "filename": "example_quantum.json",
    "title": "Quantum Topological Invariants in Non-Abelian Manifolds",
    "domain": "Quantum Topology",
    "date": "2026-05-10T14:45:18Z"
  }
];

window.PACKAGE_DB = {
  "example_number_theory.json": {
    "title": "Harmonic Resonance in the Primes",
    "domain": "Analytic Number Theory",
    "article": "# Listening to the Prime Numbers\n\nPrime numbers are the atoms of arithmetic, scattered seemingly at random along the number line. But what if they aren't random? What if they are singing a chord?\n\nBy applying Fourier analysis to the gaps between prime numbers up to $10^{12}$, we discovered a faint but unmistakable \"harmonic resonance.\" \n\n## The Prime Wave\nThe distribution of primes aligns with the zeroes of the Riemann Zeta function. Our new algorithmic approach visualizes these zeroes not as points on a plane, but as intersecting standing waves.\n\nWhen we \"listen\" to these waves, patterns emerge that allow us to predict prime deserts with unprecedented accuracy.",
    "research_paper": "# Abstract\nWe present a novel numerical method for evaluating the pair-correlation conjecture of the Riemann zeta function zeroes. By constructing a modified Montgomery-Odlyzko operator, we demonstrate a sub-exponential bound on the error term for prime gaps.\n\n## Introduction\nThe distribution of primes $\\pi(x)$ is asymptotically $\\frac{x}{\\ln x}$. However, local fluctuations are famously linked to the critical line $\\Re(s) = \\frac{1}{2}$.\n\n## Main Results\n**Theorem (Prime Resonance)**: For $N > 10^8$, the normalized gap variance satisfies:\n\n$$ V(N) = \\int_0^1 \\left( \\frac{\\pi(x+h) - \\pi(x)}{h} - 1 \\right)^2 dx \\sim \\ln N $$\n\nThis confirms the GUE hypothesis for local spacings.",
    "future_directions": "## Next Steps\n1. **Extend to Dirichlet L-functions**\n2. **Optimize the sieve algorithm** for supercomputing clusters.",
    "demos": [
      {
        "name": "Prime Gap Visualizer",
        "code": "def is_prime(n):\n    if n < 2: return False\n    for i in range(2, int(n**0.5)+1):\n        if n % i == 0: return False\n    return True\n\n# Find prime gaps\nprimes = [p for p in range(2, 1000) if is_prime(p)]\ngaps = [primes[i] - primes[i-1] for i in range(1, len(primes))]\nprint(\"Max gap under 1000:\", max(gaps))"
      }
    ],
    "algorithms": [
      {
        "name": "Fast Zeta Zero Approximation",
        "pseudocode": "Require: T > 0\n1: Evaluate Riemann-Siegel formula up to N terms\n2: Compute Z(t) for t in [T, T+10]\n3: Find sign changes to locate roots\n4: return roots"
      }
    ],
    "visualizations": [
      {
        "name": "Zeta Zero Density",
        "description": "Density of zeros along the critical line.",
        "data": "<svg width=\"200\" height=\"100\" xmlns=\"http://www.w3.org/2000/svg\"><rect width=\"200\" height=\"100\" fill=\"#161920\"/><path d=\"M0 50 Q 50 10, 100 50 T 200 50\" fill=\"none\" stroke=\"#c084fc\" stroke-width=\"3\"/><circle cx=\"50\" cy=\"50\" r=\"4\" fill=\"#fff\"/><circle cx=\"150\" cy=\"50\" r=\"4\" fill=\"#fff\"/></svg>"
      }
    ],
    "lean_proofs": "import Mathlib.NumberTheory.Primes\n\n-- Prime gap theorem placeholder\ntheorem prime_gap_bound (n : \u2115) (hn : n > 0) : \n  \u2203 p q : \u2115, p.Prime \u2227 q.Prime \u2227 p < q \u2227 q - p \u2264 n := by\n  sorry"
  },
  "example_quantum.json": {
    "title": "Quantum Topological Invariants in Non-Abelian Manifolds",
    "domain": "Quantum Topology",
    "article": "# The Shape of Quantum Space\n\nImagine trying to tie a knot in a space that constantly shifts its geometry. In our latest breakthrough, we explore the strange world of **Non-Abelian Manifolds**\u2014spaces where the order in which you travel matters. \n\nWe discovered that certain topological invariants, which usually remain constant, actually fluctuate in a predictable quantum manner when exposed to high-energy tensor fields. \n\n## Why it matters\nThis means that stable quantum memory might be possible by *braiding* particles in these spaces, protecting them from decoherence. \n\n> \"The universe isn't just curved; it's intricately braided.\"",
    "research_paper": "# Abstract\nWe formalize the notion of a fluctuating Jones polynomial over a dynamic non-abelian manifold $\\mathcal{M}$. By introducing a quantum connection $\\nabla_Q$, we prove that the holonomy of braided loops exhibits robustness against continuous local perturbations.\n\n## Introduction\nIn standard knot theory, invariants $J(K)$ are static. However, when $K$ is embedded in a quantum space with metric fluctuations... \n\n## Main Results\n**Theorem 1**: The expected value of the quantum holonomy $\\mathbb{E}[H(K)]$ is invariant under local homotopies of magnitude $\\epsilon < \\frac{\\hbar}{2mc}$.\n\n$$\\oint_K \\nabla_Q = \\sum_{i=1}^n \\lambda_i \\operatorname{Tr}(U_i)$$",
    "future_directions": "## Breakthrough Opportunities\n1. **Generalize to 4D Spacetime**\n2. **Physical implementation via Anyons**\n3. **Cryptographic applications** using braided keys.",
    "demos": [
      {
        "name": "Simulate Braid Group",
        "code": "def braid(sigma_i, sigma_j):\n    # Simulate the Artin braid group relation\n    if abs(i - j) == 1:\n        return sigma_i * sigma_j * sigma_i == sigma_j * sigma_i * sigma_j\n    return sigma_i * sigma_j == sigma_j * sigma_i\n\nprint(\"Braid simulation complete.\")"
      }
    ],
    "algorithms": [
      {
        "name": "Quantum Holonomy Approximation",
        "pseudocode": "Require: Knot K, Precision eps\n1: Initialize H = IdentityMatrix()\n2: for segment in K:\n3:    H = H * ComputeLocalConnection(segment)\n4:    if Noise() > eps:\n5:        ApplyCorrection()\n6: return Trace(H)"
      }
    ],
    "visualizations": [
      {
        "name": "Trefoil Knot Embed",
        "description": "A visualization of the quantum fluctuations around a trefoil knot.",
        "data": "<svg width=\"200\" height=\"200\" xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M100 20 C150 20, 180 80, 150 130 C120 180, 50 150, 50 100 C50 50, 120 50, 150 100 C180 150, 100 180, 50 130 C20 80, 50 20, 100 20\" fill=\"none\" stroke=\"#3b82f6\" stroke-width=\"4\"/></svg>"
      }
    ],
    "lean_proofs": "import Mathlib.Topology.Instances.Real\n\n-- Quantum invariant theorem placeholder\ntheorem quantum_holonomy_invariant (K : Knot) : \n  Continuous (fun \u03b5 => quantumHolonomy K \u03b5) := by\n  sorry"
  }
};
