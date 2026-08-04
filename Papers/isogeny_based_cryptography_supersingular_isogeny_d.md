# Build status

Lean toolchain `leanprover/lean4:v4.28.0`, Mathlib `v4.28.0`.

**The whole repository builds.**  `lake build` from the repository root compiles
every declared library — `Algebra`, `Applications`, `Bridges`, `Combinatorics`,
`Computation`, `Cryptography`, `Logic`, `MachineLearning`, `Novelty`, `Physics`,
`Probability`, `Shared`, `Speculative`, `Tropical` — with no errors, no `sorry`
and no `admit` anywhere in `Catalog/`.

## Mission files (Isogeny/SIDH)

All compile with no `sorry` and no extra axioms
(`propext`, `Classical.choice`, `Quot.sound` only):

* `Catalog/Cryptography/IsogenySIDH/KaniLemma.lean`
* `Catalog/Cryptography/IsogenySIDH/RadicalMontgomery.lean`
* `Catalog/Cryptography/IsogenySIDH/DeepRadicalMontgomery.lean`

## Build configuration

The root `lakefile.toml` now points every library at the `Catalog/` source
directory (`srcDir = "Catalog"`); previously the libraries were declared with no
source directory at the root, so `lake build` built nothing there.  The four
library targets `EML`, `Geometry`, `NumberTheory` and `Pythagorean` are not
declared: they have no source directory in this repository and aborted the
build.

## Repairs to the `Shared/` scratch library

`Shared/` held 56 files that did not compile; they are auto-generated or
partially copied artefacts of unrelated projects.  All 56 now build.  No
declaration was lost: the set of declaration names in every repaired file is a
superset of the original one.  The defects and their fixes:

* **Header order** — the module docstring was emitted before `import Mathlib`.
  The header is now normalised (imports first).
* **Declaration order** — declarations were emitted in arbitrary order, so a
  proof could refer to a lemma or definition appearing later in the same file.
  Declarations are now topologically sorted by their dependencies, keeping the
  original order wherever possible.
* **Missing base declarations** — files used `softplus`, `logisticSigmoid`,
  `one_plus_exp_pos`, `spb`, `spbH`, `spbMat`, `crossRatio`, `cauchy_pullback`,
  `tan_add_eq_spb`, `eml`, `emlDiag`, `cayley`, `IsPythTriple`, `quatNorm`, `E`
  (remainder), `IsPT`, `invB1`/`invB2`/`invB3` and the Berggren positivity case
  lemmas without defining them.  The missing definitions were supplied (matching
  the use sites elsewhere in the repository) and the missing lemmas were proved.
* **Missing `open`s and namespaces** — bare `cos`, `sin`, `tan`, `exp`, `log`,
  `Ioi`, `det_fin_two`, `image`, `last`, `#C`, `SPB.spb` … are now resolved by
  the appropriate `open` or by qualifying the name.
* **Unbalanced `end`s**, dangling `@[ext]`, and `exact?` calls left in finished
  proofs (replaced by the terms they found).
* `Shared/Algebra/SauerShelah.lean`, `Shared/SortingThermodynamics/EntropyWork.lean`,
  `Shared/BerggrenTrees/Parent_hyp_lt.lean`,
  `Shared/BabelCodeasanovelmathematicalstructure/SalvagedBest.lean` (Plotkin and
  sphere-packing bounds for codes; the Cauchy–Schwarz column bound
  `column_disagreement_bound` is proved here) and
  `Shared/Hilbert6AxiomatizationofPhysics/SalvagedBest.lean` (effect algebras:
  the `EffectAlgebra` class, the induced order, morphisms and the Boolean
  example) needed their base layer reconstructed before the salvaged theorems
  could be checked.
* `Shared/HilbertSpace/VectorStoneWeierstrass.lean` was not Lean source but a
  unified diff of a whole file; the post-image was reconstructed from the diff
  and now compiles as a 372-line development of the vector-valued
  Stone–Weierstrass theorem.
* Two theorems in the Carmichael files (`fib_composite_has_primitive`) claimed
  the unrestricted primitive-divisor theorem, which the imported results do not
  give: they only cover `13 ≤ n ≤ 10000`.  The original statement is kept,
  commented out, next to the range-restricted version that is proved.
* Fifteen files contained no Lean code at all, only a relative path pointing at
  another file.  Where the target exists in this repository the pointer is
  resolved by an `import`; the other eleven targets do not exist, so those
  modules now consist of a docstring recording the original content verbatim.
  Likewise `Shared/NumberTheory/Primitive_Prime_Divisors_for_Composite_Index_Fibonacci_Numbers.lean`,
  which held an eleven-line diff fragment breaking off inside a lemma statement.

`tools/fix_catalog_file.py` is the script that performs the mechanical part of
this repair (header order, dependency sort, missing base declarations, `open`s).


# Computational evidence for Kani's lemma (SIDH / Castryck–Decru)

The theorem we formalize is Kani's lemma for an isogeny diamond

```
        φ  (deg a)
   E₁ --------> E₂
   |            |
 ψ |(deg b)     | ψ' (deg b)
   v    φ'      v
   E₃ --------> E₄        ψ' ∘ φ = φ' ∘ ψ
```

with associated map

```
F = (  φ    ψ'^ ) : E₁ × E₄ → E₂ × E₃,     N = a + b,
    ( -ψ    φ'^ )
```

Claims tested numerically:

1. `F^ ∘ F = [N]` and `F ∘ F^ = [N]`;
2. `ker F = { (φ^Q, ψ'Q) : Q ∈ E₂[N] }`, of order `N²`, when `gcd(a,b) = 1`;
3. `ker F ∩ (E₁ × 0) = 0` and `ker F ∩ (0 × E₄) = 0` when `gcd(a,b) = 1`;
4. all of 2–3 can fail when `gcd(a,b) > 1`.

## Model used for the experiments

Supersingular curves over `F_{p²}` are awkward to enumerate directly, so we use
the *CM (complex-multiplication) model*, which realizes genuine isogeny
diamonds: take the elliptic curve `E = ℂ/ℤ[i]`, whose endomorphism ring is the
Gaussian integers, with `deg(α) = N(α) = α ᾱ` and dual `α^ = ᾱ`.

For Gaussian integers `α, β` put

* `φ = φ' = [α]` (degree `a = N(α)`),
* `ψ = ψ' = [β]` (degree `b = N(β)`).

Since `ℤ[i]` is commutative, `ψ'∘φ = βα = αβ = φ'∘ψ`, so this is an honest
isogeny diamond in the sense of the Lean structure `Cryptography.SIDH.Diamond`
(all eight degree relations hold: `ᾱα = N(α)` etc.).

Because `ker F ⊆ (E₁ × E₄)[N]`, and `E[N] = (1/N)ℤ[i]/ℤ[i] ≅ ℤ[i]/N`, the
kernel can be computed by brute-force enumeration over `(ℤ[i]/N)²`.

## Results

Kernel sizes, coprime degrees (`ker` computed by exhaustive search over
`(ℤ[i]/N)²`, `graph` = image of `Q ↦ (ᾱQ, βQ)`):

| α | β | a | b | N | gcd(a,b) | \|ker F\| | N² | ker = graph? | ker ∩ (E₁×0) | ker ∩ (0×E₄) |
|---|---|---|---|---|---|---|---|---|---|---|
| 1+2i | 1+i | 5 | 2 | 7 | 1 | 49 | 49 | yes | 1 | 1 |
| 2+i  | 1+i | 5 | 2 | 7 | 1 | 49 | 49 | yes | 1 | 1 |
| 3+2i | 2   | 13| 4 | 17| 1 | 289| 289| yes | 1 | 1 |
| 1+4i | 1+i | 17| 2 | 19| 1 | 361| 361| yes | 1 | 1 |
| 2+3i | 2+2i| 13| 8 | 21| 1 | 441| 441| yes | 1 | 1 |
| 3    | 1+i | 9 | 2 | 11| 1 | 121| 121| yes | 1 | 1 |
| 1+i  | 2+3i| 2 | 13| 15| 1 | 225| 225| yes | 1 | 1 |

Non-coprime degrees (all claims degrade exactly as expected):

| α | β | a | b | N | gcd(a,b) | \|ker F\| | \|graph\| | ker = graph? | ker ∩ (E₁×0) |
|---|---|---|---|---|---|---|---|---|---|
| 1+i | 2   | 2 | 4 | 6 | 2 | 36 | 18 | no | 2 |
| 2   | 2   | 4 | 4 | 8 | 4 | 64 | 16 | no | 4 |
| 1+2i| 1+3i| 5 | 10| 15| 5 | 225| 45 | no | 1 |
| 3+i | 1+i | 10| 2 | 12| 2 | 144| 72 | no | 2 |

In every coprime instance `|ker F| = N²` exactly, the kernel coincides with the
graph of the `N`-torsion, and the kernel meets neither factor. In the
non-coprime instances the graph is a proper subgroup of the kernel and the
kernel can meet a factor nontrivially — so the coprimality hypothesis in the
formal statements `mem_ker_kani_iff`, `graphMap_injective`,
`kani_ker_inter_left/right` is necessary, not an artefact of the proof.

The identity `F^ ∘ F = [N]` was verified symbolically in the same model (it is
the `2×2` matrix identity `F^F = (αᾱ + ββ̄) I = (a+b) I`), and is proved in full
generality in `Catalog/Cryptography/IsogenySIDH/KaniLemma.lean`.

## Sequence search

The only sequence appearing is `N ↦ N²` (kernel order), OEIS A000290; no
further sequence data is relevant here.

## Script

```python
def mul(x,y,N):  (a,b),(c,d)=x,y; return ((a*c-b*d)%N,(a*d+b*c)%N)
def conj(x,N):   return (x[0]%N,(-x[1])%N)
def norm(x):     return x[0]**2+x[1]**2

def kernel(al,be):
    a,b=norm(al),norm(be); N=a+b
    R=[(u,v) for u in range(N) for v in range(N)]        # ℤ[i]/N ≅ E[N]
    ker=set()
    for x in R:
        for y in R:
            c1=tuple((p+q)%N for p,q in zip(mul(al,x,N),mul(conj(be,N),y,N)))
            c2=tuple((q-p)%N for p,q in zip(mul(be,x,N),mul(conj(al,N),y,N)))
            if c1==(0,0) and c2==(0,0): ker.add((x,y))
    graph={(mul(conj(al,N),Q,N),mul(be,Q,N)) for Q in R}
    return N,len(ker),len(graph),ker==graph
```
