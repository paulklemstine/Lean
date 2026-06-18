# Future Directions — The Algebraic Shadow of Class Number One (the "magic" of 163)

## Synthesis

`Cryptography/Heegner.lean` reframes the folklore "magic of 163" as the *finite, decidable
shadow* of the Stark–Heegner theorem. Rather than chase the transcendental near-integer
`e^(π√163) ≈ 262537412640768744` — which needs ≳24 digits of certified interval arithmetic
on `exp`, `π` and `√163` at once — we formalized the algebraic skeleton that *causes* it:

* **Rabinowitsch's phenomenon.** Euler's lucky polynomial `x²+x+41` (discriminant `-163`) is
  prime on the maximal run `x = 0,…,39` (`euler_polynomial_prime`), and this run is *sharp*
  (`euler_polynomial_sharp`). The shorter Heegner runs `x²+x+17` (`-67`) and `x²+x+11`
  (`-43`) were also verified.
* **A universal structural identity.** `rabinowitsch_boundary`: for *every* `q`, the value at
  `x = q-1` is exactly `q²`. So every prime run is forced to die at `x = q-1`; class number
  one is precisely the statement "nothing composite appears earlier."
* **The correspondence.** `heegner_correspondence`: `q ↦ 4q-1` maps `{1,2,3,5,11,17,41}`
  bijectively onto the Heegner numbers `≡ 3 (mod 4)`, `{3,7,11,19,43,67,163}`.
* **Maximality.** `heegner_largest`: 163 is the largest Heegner number — the decidable face
  of Stark–Heegner.
* **The `j`-invariant skeleton.** `ramanujan_nearest_cube`: `262537412640768744 = 640320³ + 744`,
  exposing `j((1+√-163)/2) = -640320³`.
* **Adversarial audit.** `one_six_three_not_chen`: the widely repeated "163 is a Chen prime"
  claim is **false**, since `165 = 3·5·11` is neither prime nor semiprime.

## Results summary

| Theorem | Statement | Method |
|---|---|---|
| `euler_polynomial_prime` | `x²+x+41` prime for `x<40` | native_decide |
| `euler_polynomial_sharp` | value at `x=40` is `41²`, composite | norm_num |
| `rabinowitsch_boundary` | `(q-1)²+(q-1)+q = q²` for all `q` | ring |
| `heegner_67/43_polynomial_prime` | shorter Heegner runs | native_decide |
| `heegner_correspondence` | `q↦4q-1` onto Heegner `≡3 (4)` | decide |
| `heegner_largest` / `_card` / `_squarefree` | finite Stark–Heegner facts | decide |
| `ramanujan_nearest_cube` | `= 640320³ + 744` | norm_num |
| `one_six_three_not_chen` | 163 is *not* a Chen prime | native_decide |
| `pi_163_eq_38` | `π(163) = 38` | native_decide |

## Bold, falsifiable directions for the next cycle

### 1. Certify the transcendental near-integer `|e^(π√163) − 262537412640768744| < 10⁻⁶`.
The key insight is that the entire difficulty is *interval arithmetic*: bound `π` and `√163`
by explicit rationals, propagate through a truncated Taylor series for `exp` with rigorous
remainder bounds, and the `10⁻⁶` tolerance follows. **Why now?** We have already pinned the
target integer as `640320³ + 744` (`ramanujan_nearest_cube`), so the remaining work is a
self-contained `Real`-analysis bound with a known answer — ideal for a focused proof effort
using Mathlib's `Real.exp` and `Real.pi` bound lemmas. Falsifiable: either the certified
interval contains `262537412640768744 ± 10⁻⁶` or it does not.

### 2. Prove the *exhaustive* Rabinowitsch theorem for the Heegner discriminants.
The key insight is that for each Heegner prime `q ∈ {2,3,5,11,17,41}` the run length is
*exactly* `q-1` and **no** larger `q` gives a full run (the next candidate `x²+x+q` fails
before `q-1`). **Why now?** `rabinowitsch_boundary` already supplies the universal upper
fence at `x=q-1`; combining it with a finite search over `q ≤ N` turns "163 is the last"
into a verified statement about polynomial prime-generation, decoupled from class-field
theory. Falsifiable: search `q` up to, say, `10^4` for any full-length run beyond `41`.

### 3. Formalize the discriminant ↔ class-number-one dictionary as a `Finset` bijection.
The key insight is that the nine Heegner numbers correspond to the nine fundamental
discriminants `{-3,-4,-7,-8,-11,-19,-43,-67,-163}` via `d ↦ (if d%4=3 then -d else -4d)`.
**Why now?** With `heegnerNumbers` already defined and `heegner_correspondence` proven, the
discriminant map is one more decidable `Finset.image` identity that connects our results to
the standard tables, paving the way to import Mathlib class-group machinery later.
Falsifiable: the computed image either equals the discriminant set or it does not.

### 4. Audit *all* the folklore numerology of 163 adversarially.
The key insight is that popular lists conflate genuine facts (prime, `≡3 (mod 4)`, 38th
prime, largest Heegner number) with false ones (Chen prime). **Why now?** We already
debunked the Chen-prime claim mechanically (`one_six_three_not_chen`); a systematic decidable
audit of "lucky prime", "strong prime", "Sophie Germain", "Pillai" status for 163 would
produce a certified true/false ledger, demonstrating adversarial ground-truth at scale.
Falsifiable: each property is decidable, so each verdict is a checkable Boolean.

### 5. Generalize `rabinowitsch_boundary` to a sharpness theorem for arbitrary `x²+x+q`.
The key insight is that *every* such polynomial, regardless of `q`, has a forced composite
value no later than `x = q-1` (the perfect square `q²`), so the prime-generation game is
intrinsically finite. **Why now?** The one-line `ring` identity is already in hand; promoting
it to "`x²+x+q` is never prime for all `x ≥ 0`" (for `q ≥ 2`) is a short induction-free
corollary, giving a clean general theorem that subsumes the Heegner examples as the extremal
cases. Falsifiable: exhibit a `q` whose polynomial stays prime through `x = q-1` (impossible,
since the value is `q²` — a self-checking claim).
