# Future Directions: Automatic Sequences via the k-Kernel

## Synthesis

This cycle began as a cold start: the concept brief referenced an existing catalog of
automatic-sequence machinery (`DFAO`, `kAutomatic`, `kKernel`, Nerode bridge, Boolean
closure), but a full search of the project showed **none of it actually existed**. Rather
than build on phantom foundations, we erected the theory from scratch using the
*Eilenberg kernel characterization* as the working definition of `k`-automaticity: a
sequence `a : ℕ → α` is `k`-automatic exactly when its `k`-kernel — the set of all
decimation subsequences `n ↦ a(kᵉn + r)` with `r < kᵉ` — is finite. This choice was the
decisive structural insight of the cycle: it turns every Boolean-closure property into a
one-line "image/product of a finite set is finite" argument, sidestepping the heavy
machinery of an explicit automaton model while remaining faithful to the standard theory
(the kernel is in bijection with the reachable states of the minimal DFAO).

With that definition, the closure theorems (`const`, `map`, `not`, `prod`, `boolCombine`)
fell out immediately, because the kernel of a derived sequence always embeds into the
image of the kernels of its constituents. The flagship result — **Thue–Morse is
2-automatic** — reduced to a single number-theoretic identity: carry-free additivity of
the binary digit-sum, `tm(2ᵉn + r) = tm(r) ⊕ tm(n)` for `r < 2ᵉ`, proved by induction on
the exponent and a low-bit split. The payoff is sharp: the 2-kernel of Thue–Morse is
contained in the explicit two-element set `{tm, not∘tm}`, the tightest possible bound for
a non-constant Boolean sequence.

Nothing was disproved this cycle, but the critique exposed the precise boundary where
automaticity stops being cheap: the kernel bound is sharp at exactly two elements
(a singleton kernel forces a constant sequence), and the *real* difficulty — Cobham's
multiplicative-independence barrier — lives one level up, in proving that simultaneous
2- and 3-automaticity forces eventual periodicity. We seeded that frontier with two
explicit conjectures (`cobham_two_three`, `thueMorse_not_eventuallyPeriodic`) carrying
`sorry`, which the next team should attack.

## Results Summary

- `self_mem_kKernel`: proved — every sequence lies in its own kernel (`e=r=0`), the base point of the theory.
- `IsKAutomatic.const`: proved — constant sequences are `k`-automatic (singleton kernel).
- `IsKAutomatic.map`: proved — pushing a sequence through any function preserves `k`-automaticity (kernel maps onto kernel).
- `IsKAutomatic.not`: proved — complementation of a Boolean automatic sequence is closed (special case of `map`).
- `IsKAutomatic.prod`: proved — pointwise pairing of two `k`-automatic sequences is `k`-automatic (kernel embeds in a product).
- `IsKAutomatic.boolCombine`: proved — **Boolean closure**: any binary Boolean combination of two `k`-automatic sequences is `k`-automatic.
- `tm_two_mul`: proved — Thue–Morse even recurrence `tm(2n) = tm(n)`.
- `tm_two_mul_add_one`: proved — Thue–Morse odd recurrence `tm(2n+1) = !tm(n)`.
- `thueMorse_add_pow_two`: proved — **carry-free additivity** `tm(2ᵉn + r) = tm(r) ⊕ tm(n)` for `r < 2ᵉ`.
- `thueMorse_kernel_subset`: proved — the 2-kernel of Thue–Morse is contained in `{tm, not∘tm}`.
- `thueMorse_isKAutomatic`: proved — **the Thue–Morse sequence is 2-automatic**.
- `cobham_two_three`: conjecture (`sorry`) — a sequence that is both 2- and 3-automatic is eventually periodic (Cobham, 1972).
- `thueMorse_not_eventuallyPeriodic`: conjecture (`sorry`) — Thue–Morse is not eventually periodic (boundary witness for Cobham).

## Research Directions

### Direction 1: Thue–Morse is not eventually periodic
**Hypothesis**: `¬ EventuallyPeriodic tm`, i.e. there is no `p > 0` and threshold `N`
with `tm(n+p) = tm(n)` for all `n ≥ N`.
**Test**: For a candidate period `p`, exhibit arbitrarily large `n` with `tm(n+p) ≠ tm(n)`.
A clean route: use `thueMorse_add_pow_two` to evaluate `tm` on positions of the form
`2ᵉ` and `2ᵉ + p`; the cube-free / overlap-free structure of Thue–Morse gives a parity
mismatch. The key insight is that `tm(2ᵉ) = tm(1) = true` for every `e`, so the value at
the "powers of two" subsequence is constant while neighbouring values oscillate — a
periodic tail cannot reconcile both.
**Why now**: We already have the carry-free additivity identity, which computes `tm` at
shifted powers of two in closed form — the exact tool a periodicity refutation needs.
**If true**: It discharges the boundary witness for Cobham and proves (with
`thueMorse_isKAutomatic`) that Thue–Morse is the canonical *non-periodic* automatic
sequence, certifying that the two-element kernel bound is genuinely attained.
**If false**: It would contradict a classical theorem and signal a bug in the `tm`
definition or the additivity identity — a valuable consistency check.

### Direction 2: Exact kernel cardinality (sharpness)
**Hypothesis**: `(kKernel 2 tm).ncard = 2`; more generally, a Boolean sequence has a
singleton 2-kernel iff it is constant.
**Test**: Prove `tm ≠ (fun n => !tm n)` (e.g. evaluate at `n=0`: `false ≠ true`) to show
the inclusion `kKernel 2 tm ⊆ {tm, not∘tm}` is an equality, then compute `ncard`.
The key insight is that distinctness of the two kernel representatives is witnessed at a
single index, so sharpness is elementary once the superset bound is in hand.
**Why now**: `thueMorse_kernel_subset` already pins the kernel between a 1- and a
2-element set; only the lower bound (non-constancy) remains.
**If true**: It upgrades "finite kernel" to "kernel of size exactly 2", giving the
minimal DFAO state count and a template for measuring automatic complexity.
**If false**: It would mean `tm = not∘tm`, an immediate contradiction — so this is a
low-risk, high-certainty target.

### Direction 3: Kernel-size submultiplicativity under Boolean combination
**Hypothesis**: `(kKernel k (fun n => op (a n) (b n))).ncard ≤ (kKernel k a).ncard * (kKernel k b).ncard`.
**Test**: Refine the proof of `IsKAutomatic.boolCombine` to track cardinalities: the
kernel of the combination is the image of a subset of the product kernel, and `ncard` of
an image is bounded by `ncard` of the source. The key insight is that the *same* product
embedding that proves finiteness also yields the multiplicative state bound — the
quantitative content was there all along, just not extracted.
**Why now**: `IsKAutomatic.prod` and `IsKAutomatic.map` are already in place; only the
`Set.ncard` bookkeeping is missing.
**If true**: It gives explicit DFAO state-complexity bounds for verified Boolean
combinations of automatic generators — the quantitative backbone for the
"verifiable stream cipher" application in the original brief.
**If false**: The failure would localize to non-injectivity of the combining map,
pointing at exactly which Boolean operations cause kernel collapse (e.g. `op = const`).

### Direction 4: Closure of automaticity under finite modification and shift
**Hypothesis**: If `a` is `k`-automatic then so is every shift `fun n => a (n + c)` and
every finite modification of `a`.
**Test**: For the shift, express `kSub k (a ∘ (·+c)) e r` in terms of finitely many
`kSub k a e' r'` by a digit-carry case analysis; conclude the kernel stays finite.
The key insight is that a base-`k` shift only perturbs the low-order digits, so a shifted
decimation is a finite Boolean combination of unshifted ones.
**Why now**: The kernel framework makes "finitely many representatives" the only thing to
check, and the additivity lemma `thueMorse_add_pow_two` is a worked prototype of the
required digit-carry bookkeeping.
**If true**: It shows `IsKAutomatic` is closed under the affine reindexing group,
a prerequisite for the Büchi–Bruyère first-order decidability programme.
**If false**: It would reveal that the kernel definition is too rigid and needs the
"eventual" relaxation (kernels finite *up to* eventual equality), refining the very
definition of automaticity.

### Direction 5: Cobham's multiplicative-independence barrier
**Hypothesis**: `cobham_two_three` — a Boolean sequence that is both 2-automatic and
3-automatic is eventually periodic.
**Test**: Combine Direction 1 (Thue–Morse not eventually periodic) with a proof that
Thue–Morse is *not* 3-automatic, giving a concrete instance of the barrier; then attack
the general statement via the syndeticity/pigeonhole argument on base-2 vs base-3
representations of large integers. The key insight is that multiplicative independence of
2 and 3 makes the two digit-length functions `⌊log₂ n⌋` and `⌊log₃ n⌋` incommensurable,
so a single sequence cannot have *both* kernels finite unless its structure is trivial
(eventually periodic).
**Why now**: We now possess a complete, axiom-clean kernel formalization and a fully
worked 2-automatic example, so the only remaining ingredient is the number-theoretic
incommensurability lemma — squarely within reach of Mathlib's `Nat.digits` and
`Nat.log` APIs.
**If true**: It would be the first formal proof of (a case of) Cobham's theorem, the
deepest structural result in automatic-sequence theory.
**If false**: A counterexample would overturn a fifty-year-old theorem; far more likely,
a failed attempt will pinpoint exactly which incommensurability estimate is the true
bottleneck, directing the next several cycles.
