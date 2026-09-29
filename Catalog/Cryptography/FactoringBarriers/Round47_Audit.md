# Round 47 part 9 — the control report: the method is circular, proven

**2026-09-29. An adversarial agent re-derived every claim without touching a round-47
script. It confirms the circularity I found, proves it with an experiment I did not have,
and breaks two further claims. The 12/12 is vacuous as a factoring result. The existence
claim survives.**

---

## 1. D1 — CONFIRMED, FATAL. Step 2 factors `N`.

I had already shown `N² | disc(E)` and inferred circularity. The audit shows it is not an
inference — it is the mechanism, and it is provable by a matched-twin control.

The 2-descent runs on the cubic `θ³ + aθ + b` with `a = −3mc`, `b = c² + m³c`, whose
discriminant is

> `−4a³ − 27b² = −27c²(m³ − c)²`  —  a square times `−27`.

and step 1 sets `c := m³ mod N`, so `N | (m³ − c)` and the discriminant is divisible by
`N²`. **Factoring the discriminant returns `p` and `q`.** Verified on the table instances:
`N=4189, m=59, c=118 → disc = [2,3,7,59,71]`; `N=5461, m=28, c=108 → [2,3,43,127]`.

**The control that settles it** — two curves of *identical coefficient size*, differing only
in whether the discriminant is factorable: `a = 3s², b = 2s³` (smooth, `disc = 216s⁶`) vs
`a = 3s², b = 2s³ + 1` (hard, `disc = 27(2s³+1)²`).

| `s` (bits) | `disc` (bits) | SMOOTH `ellrank` | HARD `factor` | HARD `ellrank` |
|---|---|---|---|---|
| 40 | 244 | **0.02 s** | timeout >90 s | **timeout >300 s** |
| 59 | 357 | **0.02 s** | timeout >90 s | **1 GB stack overflow, 25 s** |
| 80 | 483 | **0.03 s** | timeout >90 s | **timeout >300 s** |

**`ellrank` needs the discriminant's prime factorisation, and for these curves that
factorisation is `N`.** `p` and `q` appear inside `ellrank`, in step 2.

> **The 12/12 is vacuous as a factoring result.** The twelve *relations* are genuine (D7
> below). The *procedure* that found them used the answer.

**What the method costs when done honestly, in one number.** Recovering the published
`(u,v)` for each table row by brute force: `N=2201 → (−4,1)`, `N=3953 → (43,112)`,
`N=1829 → (399,2960)`, and **`N=4189 → (788393, 51900)`, a 2.5×10¹²-pair search box** —
against the 8,281 pairs my scanner used. Mordell–Weil reaches it in milliseconds **by
factoring `N`**.

## 2. D2 — CONFIRMED. `chi_P` is not a homomorphism on `E(Q)`.

`Round47_MordellWeil.md` §5 rested on "`chi_P` is a character, so it is decided by a
basis." The first half is right — **positive control: `chi(l₁l₂) = chi(l₁)chi(l₂)`, 69
tests, 0 violations.** But the Jacobian transports the *curve* group law, **not
multiplication of relations**, so `chi_P` restricted to `E(Q)` is not a homomorphism:

- with all three values strictly in `{±1}`: **39/1243 violations; 3 of 15 instances are not
  homomorphisms** (`5461/(108,28)`: 10/18; `1829/(368,13)`: 22/63; `2077/(263,22)`: 7/18);
- **§5's "checkable from a basis" is therefore false on a second, independent ground.**

**But the verdict is not refuted.** On all **200** instances where step 5 fires, searching to
`|n| ≤ 14` plus all pairwise sums found **0** points with `chi_P = −1`. The *argument* is
refuted; the *conclusion* ("no relation for this `f`") held in every case tested.

## 3. D3 — CONFIRMED. Step 3 is undefined on 83.4% of instances.

`t = (Y − mX + c) / (2(X − m²))` is `0/0` at `X = m²`. The missing point is

> **`B = (m², m³ − c) ↔ (t, y) = (m/4, 3m²/8)`**, from `m⁴ − mc = 4t(m³ − c)`. Unique, always
> on `E`, verified on 6 instances.

**426/511 = 83.4%** of instances have a basis element sitting exactly there, and 20/511 have
`chi_P = 0` there. The one-line fix moves the "obstruction real" count 202 → 200.
Procedurally necessary, numerically minor.

## 4. D4 — CONFIRMED. My rank claim was wrong.

`Round47_MordellWeil.md` §2: *"ranks run 1 to 5, with only a handful at rank 1."* Measured
distribution: `{0: 2, 1: 119, 2: 247, 3: 110, 4: 30, 5: 3}`. **Rank 1 is 23%, not "a
handful", and rank 0 occurs twice** — which §2 says does not happen.

## 5. D5/D6/D7/D8/D9

- **D5** The shipped `Round47_mordell_weil.py` never raises the PARI stack and wraps
  everything in `except: print("FAILED")` — the survivorship worry C3 raises is built into
  the code. Benign in fact (0 errors occurred) but it cannot distinguish "no relation" from
  "PARI gave up".
- **D6 — GOOD.** The 62% is **neither survivorship nor too-shallow**: 309/511 = **60.5%**,
  **zero `ellrank` errors**, saturating at depth 2 (`|n|≤1 → 58.7%`, `≤2 → 60.5%`,
  `≤24 → 60.5%`). **That measurement stands.** (The 488/511 discrepancy is unresolved: no
  script produced the 488.)
- **D7 — GOOD.** All twelve rows are **genuine NFS relations with no leakage**: recovered
  `(u,v)` by an independent search from the published `(a,b,c)`; `c ≡ m³ mod N`;
  `l(m) = w²` in **Z**; `l(α) = g²` in **Z[α] exactly**, three integer coefficients, not mod
  `pq`; the gcd nontrivial with product `N`; `N` two primes `≡ 3 mod 4`. Negative controls
  all fired. `m` is incremented and `c` read off as `m³ mod N`; the twelve `N` are the first
  twelve of the verifier's list, so not cherry-picked. **The algebra is sound.**
- **D8 — GOOD.** The Jacobian cross-check is fully verified: `I = 144cm`,
  `J = −1728c(c+m³)`, `27I = 6⁴·3mc`, `−27J = 6⁶·(c²+m³c)` — `λ = 6` exact — checked
  pointwise on 27 **self-constructed** points (not map-produced), and `#C(F_p) = #E(F_p)` at
  22 good primes. **No shared use of `m³ = c`.**
- **D9.** The smoothness gate is heavy: `B(t)` numerators 16–118 bits with largest prime
  factors up to **102 bits** (`N=4189`: lpf `3671056429164690932172779046661`); 8 of 12 exceed
  2²⁰.

## 6. Standing correction to my own tooling notes

`P("default(parisize, 128<<20)")` **does not** raise the PARI stack; PARI answers *"the PARI
stack overflows… You can use `pari.allocatemem()`"*, and `P.allocatemem(1024<<20)` is the
call that works. Everything I wrote about the stack was wrong, including the note in
`Round47_general_cubic.py`.

## 7. Net position after the control

| claim | verdict |
|---|---|
| the relations are genuine NFS relations | **HOLDS** (D7) |
| the Jacobian and its derivation | **HOLDS** (D8) |
| `chi_P(l₁l₂) = chi_P(l₁)chi_P(l₂)` | **HOLDS** (69/69) |
| 62% of `(m,c)` admit no `chi_P = −1` point | **HOLDS** (D6, 60.5%, no errors) |
| **"12/12 factors recovered"** | **VOID as a factoring result** (D1) |
| **"decidable failures from a basis"** | **FALSE** (D2, and the basis is circular) |
| rank distribution | **MY CLAIM WRONG** (D4) |
| a factoring method | **NO** |

**The honest summary of round 47:** it produced a correct characterisation of the
Lee–Venkatesan obstruction as a group-theoretic question on an explicit cubic, a verified
algebraic reduction from a relation with an opposed branch to a factor of `N`, and a clean
measurement of how often such a relation exists — **and no method**, because the only
efficient way found to *locate* those relations factors `N` to do it.

The one thing that would change this is a way to generate the relations without a descent —
and the audit's `N=4189` row, needing a 2.5×10¹²-pair box, is the size of that problem.

### 7a. A rebuttal to D3, and a note on the failure mode

D3's missing point `(m/4, 3m²/8)` is **right at `P = 0` and wrong for `P ≠ 0`.** Checked on
the quartic directly:

| `m` | `P` | `Q` | `A_P(m/4) == (3m²/8)²` | difference |
|---|---|---|---|---|
| 20 | 0 | −2 | **True** | 0 |
| 14 | 0 | −207 | **True** | 0 |
| 20 | 2 | −2 | False | −301 |
| 14 | 11 | −207 | False | −3355/4 |
| 19 | 4 | 256 | False | −1091/2 |

And the underlying singularity is a **`P = 0` artefact**: the inverse is `t = (Y − V)/U` with
`U = 2X − 2m² − P`, and at `X = m²` we have `U = 0` only when `P = 0`; for `P = 2, 4, 11` one
gets `U = −2, −4, −11` and `t` is perfectly well defined.

**So D3 is real for `Round47_MordellWeil.md` (which is the `P = 0` specialisation) and does
not survive `Round47_GeneralCubic.md` (which is not).** The one-line fix is still worth
applying to the `P = 0` code.

**The failure mode is worth recording, because it is the one this audit exists to catch:** D3
was generalised from a specialisation without re-checking outside it — which is precisely how
`Klein–Kurban–Lenstra` and the other phantom citations entered this record, and precisely
what I did in this same round with the `−2Pt²` term. A control that only runs at the
parameter you derived it at is not a control.
