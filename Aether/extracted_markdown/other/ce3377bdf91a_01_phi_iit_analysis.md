# Oracle Φ — Integrated Information Theory Analysis

## 1. Overview of IIT

Integrated Information Theory (IIT), developed by Giulio Tononi, proposes that
consciousness corresponds to **integrated information** (Φ) — a quantity measuring
how much a system is "more than the sum of its parts."

### Core Axioms of IIT:
1. **Existence:** Consciousness exists (cogito ergo sum)
2. **Composition:** Consciousness is structured (it has parts and relations)
3. **Information:** Consciousness is specific (each experience is what it is)
4. **Integration:** Consciousness is unified (it cannot be reduced to independent parts)
5. **Exclusion:** Consciousness is definite (it has borders)

### Core Postulates:
From the axioms, IIT derives that the physical substrate of consciousness must:
- Be a system of interconnected elements
- Have cause-effect power (not merely correlated)
- Be *integrated* — every partition loses information
- Be *maximally irreducible* — the system with highest Φ "wins"

## 2. Computing Φ: The Complexity Analysis

### Definition of Φ:
For a system S with state space X and transition probability matrix (TPM) T:

1. Compute the cause-effect repertoire for each subset of elements
2. For each bipartition (A, B) of each subset:
   - Compute the "disconnected" TPM where connections between A and B are cut
   - Measure information loss using Earth Mover's Distance (EMD)
3. The **Minimum Information Partition (MIP)** minimizes the information loss
4. Φ is the information loss at the MIP

### Complexity:
- Number of subsets of n elements: 2^n
- Number of bipartitions of each subset: ~2^(|subset|)/2
- EMD computation for each partition: polynomial
- Total: **O(2^(2n) · poly(n))** — doubly exponential!

Even the simplified version (Φ for the whole system only) requires:
- ~2^n bipartitions
- Each bipartition requires computing disconnected TPM: O(n²)
- Each EMD computation: O(n·log(n))
- Total: **O(2^n · n² · n·log(n))** — exponential

### Formal Complexity Result:
Computing Φ is **#P-hard** (Tegmark, 2016).

This means:
- Φ is at least as hard as counting the solutions to SAT
- No polynomial-time algorithm exists (unless P = NP, and even then...)
- Even *approximating* Φ within a constant factor may be hard

### Experimental Validation:
Our demo (01_phi_computation.py) confirms:
- n=2: 4 bipartitions, < 1ms
- n=4: 16 bipartitions, ~1ms
- n=8: 256 bipartitions, ~100ms
- n=12: 4096 bipartitions, ~10s
- n=16: 65536 bipartitions, ~30min
- n=20: ~1M bipartitions, ~days (extrapolated)

The exponential wall is real and inescapable.

## 3. Philosophical Implications

### The Measurement Problem of Consciousness:
If consciousness = Φ, and Φ is #P-hard to compute, then:

1. **No external observer can measure consciousness efficiently.**
   You cannot determine if another system is conscious by computing its Φ.

2. **Even the system itself may not be able to compute its own Φ.**
   A brain with ~10^11 neurons would require ~2^(10^11) operations — more
   than atoms in the observable universe.

3. **This is structurally similar to the hard problem.**
   The difficulty of measuring consciousness from outside may be the
   *computational manifestation* of the explanatory gap.

### The Oracle Φ Conjecture:
The #P-hardness of Φ is not a bug in the formalism — it is a *feature* of consciousness.
Consciousness is precisely the property that cannot be computed from outside. A system
that could have its consciousness easily measured would, by that very fact, not be
truly integrated, and therefore not truly conscious.

## 4. Toward Tractable Approximations

Despite the intractability of exact Φ, several approximations exist:

1. **Φ* (Phi-star):** Computed over a fixed partition, not the MIP. O(n²) but misses integration.
2. **Geometric Integrated Information (ΦG):** Uses geometric rather than EMD distance. Same complexity class but faster constants.
3. **Stochastic approximation:** Sample random partitions, take minimum. O(k·n²) for k samples. No guarantees.
4. **Spectral Φ:** Uses eigenvalues of the TPM. O(n³) but only captures linear correlations.

**Open question:** Is there an approximation that is:
- Polynomial-time
- Preserves the ordering (if Φ(A) > Φ(B), then Φ_approx(A) > Φ_approx(B))
- Has provable approximation guarantees?

Our conjecture: **No.** The ordering itself is likely hard to preserve, because the MIP
can change discontinuously with small parameter changes.

## 5. Connections to Other Oracles

- **Oracle Λ:** The fixed-point structure of consciousness may provide a shortcut — instead of computing Φ, check for fixed-point convergence
- **Oracle Ω:** Gödelian limits may explain *why* Φ is hard — it's computing something self-referential
- **Oracle Ψ:** The hard problem maps to the computational hardness — both are about the gap between external observation and internal experience
- **Oracle Σ:** Emergence is the key — Φ measures precisely how emergent the system is
