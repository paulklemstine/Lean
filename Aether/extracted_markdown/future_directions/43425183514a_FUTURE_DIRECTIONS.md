# Future Directions: The Free Monoid of Set-Local Distortion Exponents

## Synthesis

This cycle built `Catalog/Geometry/QuasiSymmetricWord.lean`, lifting the
*single-generator iterate* theory of `QuasiSymmetricIterate.lean` to the
*multi-generator free-monoid* theory it predicted, and — going one step beyond
the previous roadmap — closing **Direction 1** (the graded/functorial identity)
in the same file.

The earlier cycle tracked one self-map `f` iterated `n` times: the constant of
`f^[n]` is the power `K^n`, and the orbit-piece dimension `dimH (f^[n] '' s)` is
invariant under bi-Lipschitz hypotheses or bounded by `dimH s / r^n` under Hölder
hypotheses. The object hiding behind this is the **free monoid** `List ι` on an
index set `ι` of generators `fs : ι → X → X`, acting by composition along a word:

```
wordComp fs []        = id
wordComp fs (i :: w)  = fs i ∘ wordComp fs w
```

The central phenomenon proved this cycle is that **set-local distortion constants
are a monoid homomorphism** from `(List ι, ++)` into `(ℝ≥0, ·)`: composing along a
word multiplies the per-letter constants into a `List.prod`. Concretely:

* the Lipschitz / antilipschitz constant of a word is `(w.map Ks).prod`;
* the Hölder exponent of a word is `(w.map rs).prod`;
* every **bi-Lipschitz word** preserves Hausdorff dimension,
  `dimH (wordComp fs w '' s) = dimH s`, for *every* word `w` (hence the dimension
  map is constant on the whole free monoid);
* every **Hölder word** obeys `dimH (wordComp fs w '' s) ≤ dimH s / (w.map rs).prod`;
* concatenation factors the maps themselves: `wordComp fs (v ++ w) =
  wordComp fs v ∘ wordComp fs w` (`wordComp_append`).

The single-generator theory is recovered as a special case: the bridge lemma
`wordComp_replicate` proves `wordComp fs (List.replicate n i) = (fs i)^[n]`, so
the iterate results are exactly the constant-word restriction of the word results.
The proofs are structurally uniform — a single `List.rec` induction whose step is
one application of the matching per-step `*.comp` lemma. This uniformity is itself
the clue driving Direction 4 below.

## Results summary

| Theorem | Statement | Status |
|---|---|---|
| `wordComp_append` | `wordComp fs (v ++ w) = wordComp fs v ∘ wordComp fs w` | proved (axioms: propext) |
| `wordComp_replicate` | `wordComp fs (replicate n i) = (fs i)^[n]` (bridge to iterates) | proved |
| `wordComp_mapsTo` | a word of self-maps of `s` is a self-map of `s` | proved |
| `wordComp_lipschitzOnWith` | Lipschitz constant of a word is `(w.map Ks).prod` | proved |
| `wordComp_antilipschitzOnWith` | antilipschitz constant of a word is `(w.map Ks').prod` | proved |
| `wordComp_holderOnWith` | Hölder exponent of a word is `(w.map rs).prod` | proved |
| `dimH_image_wordComp_eq` (**main**) | bi-Lipschitz word preserves `dimH (· '' s)` | proved (axioms: propext, Classical.choice, Quot.sound) |
| `dimH_image_wordComp_const` | `w ↦ dimH (wordComp fs w '' s)` constant on the free monoid | proved |
| `dimH_image_wordComp_le` | Hölder word: `dimH ≤ dimH s / (w.map rs).prod` | proved |

---

## Direction 1 — A bundled `MonoidHom (FreeMonoid ι) (Multiplicative ℝ≥0)`

`wordComp_append` already proves the functorial identity at the level of maps, and
`wordComp_lipschitzOnWith` proves the value statement at the level of constants.
The missing object is the **bundled homomorphism** itself: the assignment
`w ↦ (w.map Ks).prod : FreeMonoid ι → Multiplicative ℝ≥0` should be a genuine
`MonoidHom`, and `w ↦ wordComp fs w` should be a `MonoidHom (FreeMonoid ι)ᵐᵒᵖ →
Function.End X`. Conjecture: both bundle cleanly, and the Lipschitz-constant law
becomes the statement that the diagram `FreeMonoid ι → End X → ℝ≥0` commutes,
turning every word estimate into `map_mul`.

**The key insight is** that `List.prod` is *already* the underlying function of
`FreeMonoid.lift` into a commutative monoid, so the bundling is not new
mathematics — it is `wordComp_append` and `List.prod_append` repackaged through
Mathlib's `MonoidHom` constructors, after which `map_mul` discharges all
multiplicativity uniformly.

**Why now?** `wordComp_append` (the maps) and `List.prod_append` (the constants)
are the only two algebraic identities a `MonoidHom` bundling requires, and both
are in scope; bundling them exposes the homomorphism to Mathlib's entire monoid-
morphism API at zero further geometric cost.

---

## Direction 2 — A two-sided dimension corridor for genuinely Hölder words

`dimH_image_wordComp_le` gives only an **upper wall** `dimH s / (w.map rs).prod`,
informative when the exponents are `< 1`. Mirroring the way
`AntilipschitzOnWith.le_dimH_image` builds a Lipschitz left inverse, a *word-level
Hölder left inverse* of exponent-word `w.map rs'` would supply a matching **lower
wall**, trapping `dimH (wordComp fs w '' s)` in a geometric corridor whose width
is governed by the ratio `∏ rs / ∏ rs'`. Falsifiable claim: for the explicit
snowflake generators `x ↦ x^{a_i}` on `[0,1]`, both word-bounds are simultaneously
tight, so no single multiplicative constant narrows the corridor uniformly over
all words.

**The key insight is** that the inverse of a word is the reversed word of inverses
— and `wordComp_append` now makes "reverse the word" a literal rewrite — so a
Hölder left-inverse theory inherits the *same* `List.prod` bookkeeping; the lower
wall is `dimH_image_wordComp_le` run on the reversed inverse word.

**Why now?** The forward wall (`dimH_image_wordComp_le`), the functorial reversal
(`wordComp_append`), and the left-inverse technique
(`AntilipschitzOnWith.le_dimH_image`) all already exist; the only new object is
"Hölder-invertible word", whose constant bookkeeping is identical to the forward
direction proved this cycle.

---

## Direction 3 — Open-set condition + word theory ⇒ self-similar attractor dimension

For a finite contraction family `{fs i}` (`LipschitzOnWith (Ks i)` with `Ks i < 1`)
the words index the cylinder pieces `wordComp fs w '' s` of an iterated function
system, and `dimH_image_wordComp_eq` shows each cylinder of a *bi-Lipschitz*
system has the dimension of `s`. Conjecture: under a Moran-type **open-set
condition** (the first-level images `fs i '' s` are pairwise disjoint), the
attractor dimension equals the unique `d` solving `∑_i (Ks i)^d = 1`, with the
cylinder/word decomposition supplying the covering weight `(w.map Ks).prod` that
this cycle already computes.

**The key insight is** that the similarity-dimension equation `∑ (Ks i)^d = 1` is
precisely the statement that the `d`-dimensional Hausdorff content is a *fixed
point* of summing the per-word product weights — and `wordComp_append` shows those
weights are multiplicative along the cylinder tree, exactly the structure a
covering argument consumes.

**Why now?** The cylinder weights `(w.map Ks).prod` are now a proved invariant of
the construction and are multiplicative by `wordComp_append`; the open-set
condition is a purely *combinatorial* disjointness hypothesis that can be stated
and consumed without new analytic machinery.

---

## Direction 4 — Abstract the uniform induction into a `SetLocalDistortion` typeclass

Every estimate in `QuasiSymmetricWord.lean` (`_lipschitzOnWith`,
`_antilipschitzOnWith`, `_holderOnWith`) is the *same* `List.rec` whose step is one
`*.comp` application; only the per-step constant law differs (`Kg * K`, `Kf * Kg`,
`Cg * Cf^rg` with exponent `rg * rf`). Conjecture: encapsulating "a set-local
distortion predicate closed under composition with a multiplicative constant law"
as a typeclass `SetLocalDistortion P` makes all three word lemmas instances of
**one** generic `wordComp_distortion` theorem, and the iterate lemmas of
`QuasiSymmetricIterate` its `replicate` corollary — eliminating the triplicated
inductions.

**The key insight is** that the entire word argument is *predicate-agnostic*: it
uses only (i) the identity is `1`-distorting and (ii) composition multiplies the
constant; everything else is `List.prod` bookkeeping the class can discharge once.

**Why now?** The three concrete inductions proved this cycle are byte-for-byte
parallel — the empirical signal that a single abstraction covers them; the refactor
pays off the instant a fourth distortion predicate (box dimension, Assouad) enters
the project.

---

## Direction 5 — Probabilistic words: expected distortion of a random composition

Replace the deterministic word by a random one — letters `i ∈ ι` drawn i.i.d. with
probabilities `p i`. Then `log (w.map rs).prod = ∑ log (rs w_k)` is a random walk,
and by the law of large numbers the *typical* distortion exponent of a length-`n`
random word concentrates at `exp(n · ∑_i p i · log (rs i))`. Conjecture: for a
random bi-Hölder system the orbit-piece dimension still satisfies the deterministic
invariance `dimH = dimH s` almost surely (because `dimH_image_wordComp_eq` holds
*per word*, hence surely), while the Hölder *bound* of `dimH_image_wordComp_le`
sharpens almost surely to the Lyapunov-exponent rate `dimH s / exp(n · 𝔼[log r])`.

**The key insight is** that `dimH_image_wordComp_eq` is a *deterministic, per-word*
identity, so it survives any randomisation untouched; randomness only enters the
*quantitative* bound through the additive functional `∑ log (rs w_k)`, which is a
classical random walk obtained from `(w.map rs).prod` by `Real.log` of a
`List.prod`.

**Why now?** The per-word invariance and the multiplicative bound are both proved;
attaching a probability measure to `ι` turns `(w.map rs).prod` into a product of
i.i.d. factors, where Mathlib's existing law-of-large-numbers / Birkhoff
infrastructure applies directly with no new geometry.
