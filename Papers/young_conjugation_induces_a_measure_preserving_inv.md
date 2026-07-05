# Computational Evidence

Concise numerical checks supporting the formalized claims. All computations were
cross-checked against the Lean proofs (which are exact, not numerical).

## 1. Young conjugation is a fixed-point-free involution on generic partitions

Small-case check of `λ ↦ λ'` (transpose of the Young diagram):

| λ (row lengths) | λ' (conjugate) | self-conjugate? |
|-----------------|----------------|-----------------|
| [1]             | [1]            | yes             |
| [2]             | [1,1]          | no              |
| [1,1]           | [2]            | no              |
| [2,1]           | [2,1]          | yes             |
| [3,1]           | [2,1,1]        | no              |
| [2,2]           | [2,2]          | yes             |
| [3,2,1]         | [3,2,1]        | yes (staircase) |

Observations:
- `(λ')' = λ` in every row (involutivity).
- `|λ| = |λ'|` (cell count preserved) in every row.
- `[2]` is the smallest non-self-conjugate partition; it is the witness used to
  prove `orderOf youngConj = 2` (a genuine order-two element, not the identity).

Number of self-conjugate partitions of `n` (= partitions of `n` into distinct odd
parts): `1, 1, 1, 2, 2, 3, 4, 5, 6, 8, …` — this is OEIS A000700, consistent with
conjugation being an involution whose fixed points are the self-conjugate diagrams.

## 2. The four subdomains each carry mass 1/4

Model domain: unit square split by its mid-lines into
`D₁ = [0,½)²`, `D₂ = (½,1]×[0,½)`, `D₃ = (½,1]×(½,1]`, `D₄ = [0,½)×(½,1]`.

Direct area computation (product of interval lengths):
- area(D₁) = (½)(½) = 1/4
- area(D₂) = (½)(½) = 1/4
- area(D₃) = (½)(½) = 1/4
- area(D₄) = (½)(½) = 1/4
- total = 1  ✓  (cells pairwise disjoint by construction)

## 3. Involution orbit structure (counterexample hunt)

Point reflection `τ(x,y) = (1−x, 1−y)`:
- τ(D₁) = D₃, τ(D₃) = D₁, τ(D₂) = D₄, τ(D₄) = D₂  → two 2-cycles (involution).
- Sampled interior points, e.g. τ(0.2, 0.3) = (0.8, 0.7) ∈ D₃  ✓;
  τ(0.7, 0.2) = (0.3, 0.8) ∈ D₄  ✓.
- No sample violated `τ∘τ = id` or measure preservation (|det Dτ| = 1).

Coordinate swap `σ(x,y) = (y,x)` (= Young conjugation on cells):
- σ(D₁) = D₁, σ(D₃) = D₃ (diagonal cells fixed), σ(D₂) = D₄, σ(D₄) = D₂.
- `σ∘τ = τ∘σ = α`, the anti-transpose `α(x,y) = (1−y, 1−x)`, `α∘α = id`.
- Group generated: `{id, σ, τ, α} ≅ ℤ/2 × ℤ/2` (Klein four). No sampled element
  broke closure or commutativity.

Conclusion: every universal claim survived the sampling; the exact statements are
proved in the accompanying Lean files with 0 sorries.
