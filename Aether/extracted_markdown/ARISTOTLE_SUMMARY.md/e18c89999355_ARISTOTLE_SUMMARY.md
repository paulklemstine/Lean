# Summary of changes for run 7f14eeab-705b-4bd4-bb0c-f606c0b1852b
## Completed: M-Convexity Closure Under Differentiation

### Formally Verified Mathematics (Lean 4)

**File:** `Pythagorean/MConvexDifferentiation.lean` — ~400 lines, **zero `sorry`**, builds cleanly. All proofs use only standard axioms (propext, Classical.choice, Quot.sound).

**Key theorems proved (all fully verified):**

1. **`SupportSatisfiesExchange.pderiv`** — *Main closure theorem*: If a polynomial with non-negative coefficients has M-convex support (satisfies the symmetric exchange axiom), then its partial derivative with respect to any variable also has M-convex support.

2. **`SupportSatisfiesExchange.mixedPDeriv`** — *Iterated derivative closure*: Every mixed partial derivative of such a polynomial inherits M-convex support. This establishes that the entire derivative tower remains in the world of discrete convexity.

3. **`support_pderiv_eq_supportContraction`** — *Support = Contraction correspondence*: The support of ∂p/∂xᵢ equals the support contraction (positive-i slice shifted by eᵢ) of the original support, making the differentiation-contraction dictionary precise.

4. **`SetSatisfiesExchange.contraction`** — *Contraction preserves exchange*: The core combinatorial theorem that support contraction preserves the exchange axiom, proved via witness transport.

5. **`exchangeWidth_pderiv_le`** and **`exchangeDepth_pderiv_le`** — *Cross-domain invariant monotonicity*: Exchange width and depth are non-increasing under differentiation.

**New definitions introduced:** `SupportContraction`, `SetSatisfiesExchange`, `mixedPDeriv`, `exchangeWidth`, `ExchangeDepth`, `DerivativeStableExchange`.

**Supporting lemmas:** `coeff_pderiv` (coefficient formula), `mem_support_pderiv_iff_nonneg` (support membership), `coeff_pderiv_nonneg` (non-negativity preservation), Finsupp arithmetic lemmas for exchange witness commutation.

### Proof Architecture

The proof follows Strategy A (direct support transport):
1. Establish the coefficient formula: coeff_m(∂p/∂xᵢ) = (mᵢ+1) · coeff_{m+eᵢ}(p)
2. Characterize support membership: m ∈ supp(∂p/∂xᵢ) ↔ m+eᵢ ∈ supp(p) (using non-negativity)
3. Identify derivative support with combinatorial contraction
4. Prove contraction preserves exchange by lifting vectors back to the original support, applying exchange there, and verifying the witnesses project back correctly
5. Chain for iterated derivatives using preserved non-negativity

### Other Deliverables

- **`ARTICLE.md`** — Popular science article (~2000 words) explaining how differentiation preserves hidden combinatorial structure
- **`RESEARCH_PAPER.md`** — Full research paper with abstract, proofs, algorithms, computational results, and references
- **`FUTURE_DIRECTIONS.md`** — 5 research directions including grand challenges connecting to Hodge theory and tropical geometry
- **`demo.py`** — Interactive demonstration with 5 demos: basic examples, derivative towers, counterexample search (1355 M-convex supports tested, 0 counterexamples), invariant monotonicity, matroid contraction correspondence
- **`algorithms.py`** — Documented implementations of exchange testing (O(|S|²n²)), support contraction, and derivative tower verification
- **`applications.py`** — Applications to combinatorial optimization, statistical physics (partition function conditioning), and matroid theory
- **`visualize_contraction.py`**, **`visualize_invariants.py`**, **`visualize_exchange.py`** — Three matplotlib visualization scripts (PNG outputs included)
- **`interactive_exchange.html`** — Interactive HTML/JS demo for building supports and testing exchange preservation in real-time
- **`PACKAGE.json`** — Complete JSON data package bundling all artifacts