# Future Directions: LWE-Based Key Exchange

This cycle added `Catalog/Cryptography/LWE/KeyExchange.lean`, formalizing the
algebraic and quantitative core of lattice-based key exchange (Lindner–Peikert /
Frodo style) on top of the existing `SearchDecisionCore.lean`. The new file
proves the **bilinear symmetry** that makes the two parties' shared values agree
up to noise (`lwe_ke_bilinear_symmetry`, `lwe_ke_agreement`), a concrete
coordinatewise **noise bound** on the agreement gap (`lwe_ke_dotProduct_bound`,
`lwe_ke_gap_bound`), **rounding/reconciliation correctness**
(`lwe_ke_decode_correct`, `lwe_ke_agreement_decode`), and a two-step **hybrid
security** reduction (`lwe_ke_security_hybrid`, `lwe_ke_security_advantage`).
Below are concrete, falsifiable next steps.

## 1. From a deterministic gap bound to a correctness *probability*

The current correctness statement is worst-case: `lwe_ke_gap_bound` shows the
agreement gap is at most `2nES`, and `lwe_ke_decode_correct` then guarantees
agreement when `2nES < q/4`. Real schemes instead bound the *probability* of a
decryption failure when secrets and errors are drawn from a discrete Gaussian or
centered binomial distribution. The conjecture: for errors with sub-Gaussian
parameter `σ`, the failure probability is at most `2n·exp(-(q/4)²/(2nσ²·S²))`,
i.e. exponentially small once `q = Ω(σ S √(n log n))`.

The key insight is that the agreement gap `⟨e₂,s⟩ - ⟨e₁,s'⟩` is a sum of `2n`
independent bounded-variance terms, so a Hoeffding/Bernstein tail bound converts
the deterministic `lwe_ke_dotProduct_bound` directly into an exponential failure
bound — replacing the triangle inequality by a concentration inequality. Why
now? Mathlib's `MeasureTheory` and `ProbabilityTheory` layers already contain
Hoeffding-type bounds and sub-Gaussian machinery, so the only missing piece is
wiring the existing linear-algebra identity into a martingale/independent-sum
tail argument.

## 2. Ring-LWE / Module-LWE generalization of the agreement identity

`lwe_ke_bilinear_symmetry` is stated for a square matrix `A` over an arbitrary
commutative ring `R`. The conjecture is that the *entire* agreement identity
lifts verbatim to the Ring-LWE setting where `R = ℤ_q[x]/(xⁿ+1)` and `A` is a
single ring element (or a small module matrix), giving `kA - kB = e₂·s - e₁·s'`
in the cyclotomic ring, with a coefficient-wise noise bound governed by the
ring's expansion factor.

The key insight is that the symmetry proof uses *only* commutativity and the
`mulVec`/`vecMul`/transpose adjunction, never the field structure of `ℤ_q`, so it
should specialize to polynomial multiplication once `dotProduct` is replaced by
the ring product and the noise bound is rephrased via the ring's operator norm.
Why now? The catalog already contains `Cryptography/ModuleLWE/Defs.lean` and
related Module-LWE files; bridging `KeyExchange.lean`'s ring-generic identity to
those definitions is a direct cross-file synthesis rather than new theory.

## 3. Tight reconciliation: agreement under a *single* hint bit (the q/8 regime)

`lwe_ke_agreement_decode` proves agreement when both parties are within `q/4` of
the *same* codeword. Peikert's reconciliation mechanism achieves agreement under
the weaker hypothesis that the two parties' raw values differ by less than `q/8`,
by transmitting one cross-rounding hint bit. The conjecture: there is a hint
function `hint : ℤ_q → Bool` and a reconciliation map `rec : ℤ_q × Bool → Bool`
such that `|vA - vB| < q/8` implies `rec(vA, hint vB) = ⌊vB⌉₂`, doubling the
tolerable noise versus naive rounding.

The key insight is that the hint bit records *which quarter* of `[0,q)` the value
lies in, so it disambiguates the boundary cases that break plain rounding — the
proof reduces to an interval-arithmetic case split exactly like
`lwe_ke_decode_correct`, but on four intervals instead of two. Why now? The
rounding lemmas in this file (`round_intCast_add`, `round_eq_zero_iff`) already
provide the integer-rounding API; the extension is a finite case analysis, well
within reach of `omega`/`interval_cases`-driven automation.

## 4. Composing the search-to-decision reduction with key-exchange security

`SearchDecisionCore.lean` proves the factor-`n` advantage loss of the
search-to-decision reduction, and `KeyExchange.lean` proves the factor-`2`
hybrid loss of the key-exchange transcript. The conjecture: composing the two
yields an end-to-end bound — *breaking the key exchange with advantage `ε`
implies solving search-LWE (hence, via the worst-case reduction, GapSVP) with
advantage `≥ ε/(2n)`* — as a single Lean theorem chaining
`lwe_ke_security_advantage` into `search_to_decision_advantage_bound`.

The key insight is that advantage losses *multiply* along a reduction chain while
the underlying distinguishers *compose*, so the quantitative bookkeeping is just
arithmetic on the two already-proven pigeonhole/triangle inequalities. Why now?
Both halves are already formalized in this directory; the composition is a
high-value, low-risk theorem that demonstrates the catalog's reductions are
genuinely modular.

## 5. Symmetry of the shared key as a quadratic form, and failure of the
   non-commutative analogue

`lwe_ke_bilinear_symmetry` secretly says the noise-free shared key is the
symmetric bilinear form `B(s,s') = s'ᵀ A s = sᵀ Aᵀ s'`. The conjecture (with a
companion *counterexample*): over a non-commutative coefficient ring the identity
`⟨Aᵀ·s', s⟩ = ⟨A·s, s'⟩` *fails*, and there is an explicit `2×2` matrix over the
quaternions (or over `Matrix (Fin 2) (Fin 2) ℤ`) witnessing the failure — so
commutativity is not merely convenient but necessary for the two parties to
agree.

The key insight is that the proof step `dotProduct_mulVec` silently uses
`a*b = b*a` when reindexing the double sum, so any non-commutative pair that does
not commute breaks agreement; pinning down a minimal `2×2` counterexample
sharpens exactly *where* the cryptographic protocol relies on the ring being
commutative. Why now? `KeyExchange.lean` already isolates the symmetry as a named
lemma over a generic `CommRing`, making it straightforward to state the negation
over a `Ring` and discharge the counterexample by `decide`/explicit computation.
