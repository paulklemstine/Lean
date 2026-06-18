# The Universal Translator: Space ↔ Algebra

A comprehensive research project exploring the fundamental correspondence between
geometric spaces and commutative algebras — the Rosetta Stone of modern mathematics.

## Contents

### 📐 Lean Formalization
- **`../Duality/UniversalTranslator.lean`** — Machine-verified dictionary with 30 theorems
  across 8 rows, plus Gelfand duality and the weak Nullstellensatz. **All proofs complete
  (zero sorry statements).**

### 📊 Python Demos (with visuals)
Run from the `demos/` directory:

| Script | Output | Description |
|--------|--------|-------------|
| `demo1_grand_duality_table.py` | `grand_duality_table.png` | The 8-row Space ↔ Algebra dictionary infographic |
| `demo2_spec_of_integers.py` | `spec_integers.png` | Spec(ℤ) — prime spectrum with Zariski topology |
| `demo3_contravariance.py` | `contravariance.png` | Arrow reversal: ring homs vs spectral maps |
| `demo4_zariski_topology.py` | `zariski_topology.png` | Varieties in 𝔸² — circles, parabolas, elliptic curves |
| `demo5_noncommutative_frontier.py` | `noncommutative_frontier.png` | Spectral triples & Connes distance formula |
| `demo6_idempotent_decomposition.py` | `idempotent_decomposition.png` | Connected components ↔ idempotents in ℤ/6ℤ |

```bash
cd demos && pip install matplotlib numpy && python demo1_grand_duality_table.py
```

### 📝 Research Notes
- **`notes/oracle_council_notes.md`** — Full deliberation log from the Oracle Council
  (Geometer, Algebraist, Physicist, Philosopher, Experimentalist)
- **`notes/iteration_log.md`** — Hypothesis → experiment → validation iteration record

### 📄 Publications
- **`research/research_paper.md`** — Full academic research paper with formal definitions,
  theorem statements, proof discussion, and frontier extensions
- **`research/scientific_american_article.md`** — Popular science article: "The Rosetta Stone
  of Mathematics"

## The Eight-Row Dictionary

```
SPACE                          ALGEBRA
─────                          ───────
1. Point x ∈ X          ←→    Prime ideal 𝔭 ⊂ R
2. Open set U ⊆ X       ←→    Element a ∈ R (via D(a))
3. Continuous map f      ←→    Ring hom φ (arrows reverse!)
4. Closed subspace Z     ←→    Ideal I ⊂ R (via V(I))
5. Dimension dim(X)      ←→    Krull dimension
6. Tangent vector v      ←→    Derivation δ: R → M
7. Connected components  ←→    Idempotents e² = e
8. Vector bundle E → X   ←→   Projective module P
```

## The Frontier

Beyond the table: **Noncommutative geometry** (Connes), where ab ≠ ba means
there is no classical space — but the algebraic side still works, and describes
quantum mechanics and the Standard Model of particle physics.
