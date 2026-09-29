# ROUND 47 — the single entry point

**Start here, then follow the links. Do not read the 24 `Round47_*` files in order; they were
written in the order they were believed, and several are wrong in the ways noted below.**

Round 47 ran on 2026-09-29, 31 commits, opening a direction the previous 46 rounds had not
touched and then closing it rigorously — along with finding the two "live directions" the
earlier record asserted do not exist.

---

## 1. What round 47 actually established

### 1.1 A correct and useful characterisation (new)

For the **cubic** number field sieve in Lee–Venkatesan's *square-relation* framework, the
relations are **the rational points of an explicit genus-1 curve**, with an explicit Jacobian
and an explicit quadratic character:

> `C : y² = 4t⁴ + 8mt³ − 2Pt² + (2mP + 4Q)t + (P²/4 − mQ)`,  valid for the **full** cubic
> `f = X³ + PX + Q`.
> `Jac(C) = E : Y² = V² + UW`, `U = 2X − 2m² − P`, `V = mX + mP/2 + Q`,
> `W = X²/2 − P²/8 + mQ/2`, reducing **exactly** to `Y² = x³ − 3mcx + c² + m³c` at `P=0`.
> `chi_P = Jacobi(C(t)·y, N)` — **this identity is Lee–Venkatesan's own definition, p.38; no
> novelty is claimed for it.**

Verified 1155/1155, 535/535, 22/22, 6/6. Twelve relations independently confirmed genuine in
`ℤ[α]` exactly, with no leakage. → `Round47_EllipticReduction.md`,
`Round47_GeneralCubic.md`, `Round47_Audit.md` (D7, D8).

### 1.2 The dimensional closure — the round's deepest result

Requiring `h(α) = g²` costs `d−2` dimensions, leaving a **curve for every `d`**:

| `d` | no square condition | with `h(α) = g²` | genus of the relation curve |
|---|---|---|---|
| 3 | 3 | **1** | 1 |
| 4 | 4 | **1** | **5** |
| 5 | 5 | **1** | 17 |
| 6 | 6 | **1** | 49 |

> **The constraint that makes the relation space analysable is the constraint that makes it
> thin. You cannot have one without the other.**

The ordinary NFS never pays this: it asks a *combination* of relations to have square norms,
handled by linear algebra over `GF(2)`. → `Round47_DimensionalClosure.md`,
`Round47_DegreeBarrier.md`.

### 1.3 The synthesised statement about the whole project

Conjecture 7.1 is **the price of rigour, paid twice**: once in the relation space
(dimension `d → 1`) and once in running time (the rigorous `L[1/3]` is **224.4 dex behind**
the heuristic at 2048 bits, and a true `1/6` *widens* the gap). The standard GNFS has no
Conjecture 7.1 **precisely because it is not rigorous**. → `Round47_PriceOfRigour.md`.

---

## 2. Every claim retracted this round (all mine)

| claim | why it died |
|---|---|
| `C(t)A(t)` square-class criterion for the obstruction | **refuted**, 13/24. Non-trivial on `Q(E)` does not imply non-trivial on the thin subset `E(Q)`. |
| CLAIM 47: rank > 0 ⟹ `chi_P = −1` exists | **refuted**. Rank 0 in 10%; `chi⁻¹(−1)` is not Zariski-open, so rank buys nothing. |
| **"12/12 factors recovered"** | **VOID as a factoring result.** `ellrank`'s 2-descent needs the discriminant factored, and `disc = −27c²(m³−c)²` with `N | (m³−c)` — **so it factors `N` to do it.** Proven by a matched-twin control (smooth vs hard discriminant, same coefficient size: 0.02 s vs timeout >300 s). |
| "decidable failures, decided by a basis" | **false.** `chi_P` is **not** a homomorphism on `E(Q)` (39/1243; 3 of 15 instances). The Jacobian transports the *curve* law, not multiplication of relations. |
| "you cannot choose the field at scale" | **my error.** A naive search found 15 hits against 0.001 predicted; `Q` is naturally small for `m ≈ N^{1/3}`, and NFS finds such `m` by **lattice reduction**, by design. |
| the `L`-pricing ("2.5e35", "31× worse") | **an exponent printed as a value.** `L_N[1/3,1]` at `N=10^20` is **6464**, matching the record's own `B = 6463.8`. |
| "rank 1 is only a handful" | measured `{0:2, 1:119, 2:247, 3:110, 4:30, 5:3}`. Rank 1 is 23% and rank 0 occurs twice. |
| a spurious `−2Pt²` term removal | self-test caught it: 86 mismatches. **The `t²` term is real.** |

## 3. What was corrected in the *previous* record

- **The handover's §2, "THE LIVE DIRECTION", is VOID.** Its citation — Kaltofen–Kurban–Lenstra,
  IPL 80 (2001) 57–64 — **does not exist** (complete Crossref deposit for IPL 2001: pp. 57–64
  already occupied by two process-algebra papers; no Kaltofen–Lenstra or Kaltofen–Kurban paper
  anywhere in Crossref). **And the axis is closed anyway**: arXiv:2504.08063, *"no efficient
  deterministic algorithms are known even for the seemingly easier problem of factoring sparse
  polynomials"*. Best bound: `poly(n, s^{d² log n})` — **quasi-polynomial**, not polynomial.
  **A phantom for 46 rounds.** → `Round47_PhantomSources.md`, `Round47_HandoverAddendum.md`.
- **§7b misquotes Remark 7.3.** The "no single character" sentence is conditioned on `p, q`
  **not** both `≡ 3 mod 4` — the excluded case. That wall does not exist in the paper's setting.
- **The real missing lemma, LV p. 26 verbatim**: *"much stronger versions of the Chebotarev
  Density Theorem might be required."* So it is **Chebotarev-strength *joint* character
  decorrelation**, and Conj 7.1 is its fixed-field special case — **not a proof-strategy
  artefact**.
- **The GNFS constant.** `1.923` is correct and **derived**, and does not move: Montgomery's
  block Lanczos has an `O(n²)` term **independent of `N`** (p. 118, EUROCRYPT '95) and *that
  term is the constant*; and a polylog win is swallowed by the `(1+o(1))`
  (arXiv:2006.06197 p. 4). The `ω=2` floor is `0.96150`, half of `1.92300`.
  **LV's Theorem 2.3 is `1.92299`; the `1.90188` is a separate, *asserted* Coppersmith-MPS
  extension remark** — read off a page image, because `pdftotext` mangles both. → `Round47_GNFSConstant.md`,
  `Round47_LVConstants.md`.
- **~10 further phantom citations**, most of them mine (Harvey–Hittmeir; Costa & Sharamba;
  "CRT list decoding"; Bernstein ANTS 2001; Maurer–Wolf venue; Maurer 1996 venue; KKL; ADH
  authorship; Evdokimov; Kaltofen 2000 pages; arXiv:1210.1451; Lenstra ECM pages). Also
  **arXiv:2010.01250 is "CorrAttack"**, and **arXiv:1608.08766 is Hittmeir _solo_** — the
  "Harvey &" was the fabrication.

## 4. The frontier, as it now stands

| | item | status |
|---|---|---|
| 1 | beat the GNFS **heuristic** | **closed** for the linear-algebra route, two independent ways |
| 2 | a **rigorous `L[1/3]`** | **open**. `1.92299`, conditional on Conj 7.1 = Chebotarev-strength decorrelation, untouched since 2018. Worth **224 dex less** than the heuristic. |
| 3 | **auxiliary-information factoring** | open, and the one place "a method" is literally true. **Never mined in 47 rounds** — the brief's scope includes it and the record cites zero papers in it. |

**Item 2 buys a bound 224 orders of magnitude worse than what we already use. Item 1 is closed.
So the only axis on which "a method" is a literal, honest description is item 3 — a different
problem, with methods.**

## 5. The rules round 47 earned

> **A search that fails is not a barrier until the method that would succeed has been tried.**
> *(I claimed one; my own data had refuted it four orders of magnitude.)*

> **A control that only runs at the parameter you derived it at is not a control.**
> *(An audit finding, generalised from my own specialisation without re-checking outside it —
> the exact mechanism by which the phantom citations entered this record.)*

> **Render the page.** `pdftotext` changed a conclusion **three** times today, once by
> dropping a cube root *and* a square root in the same display.

> **Write the self-test before the experiment.** It caught five of my own errors and **zero**
> of the record's.
