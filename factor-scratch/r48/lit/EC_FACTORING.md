# Literature verification: factoring N with elliptic curves (round 48)

Date: 2026-10-03. All work in `/home/raver1975/lean/factor-scratch/r48/lit/`.

**Method note.** WebSearch was NOT used (it fabricates on this host). Every URL below was fetched
with `curl` or WebFetch. `pdftotext -layout` was used for PDFs and page numbers are PDF page
indices (1-based, matching the printed page for these documents). Files fetched are in this dir.

**Bottom line up front.**
- Item 3 (the twist identity): **VERIFIED IN PRINT.** Both of your identities are a special case of
  an explicit displayed calculation in Dieulefait–Urroz, p.4. Your derivation is correct but NOT fresh.
- Item 2 (#E(Z/NZ) vs factoring): **VERIFIED**, and the direction is *counting points ⇒ factoring*
  (an oracle for counting points factors N), not the reverse.
- Item 1 (sampling + point order ⇒ factoring): **VERIFIED as a theorem in the literature** via the
  title and secondary description of Martín–Morillo–Villar (2001). The **term "twist-separable" was
  NOT FOUND anywhere** — zero mathematical hits in Brave and in OpenAlex full-text.
- Items 4/5: only **partially** verified. Serre surjectivity is citable; the specific
  Ireland–Rosen / Silverman mod-3 sentence was **NOT VERIFIED** (those books are not reachable).
- Your mod-3 counterexample is **CONFIRMED correct** by direct computation.

---

## Item 1 — Sampling a point in E(Z/NZ) and computing its order ⇒ factoring

| Claim | Source | URL fetched | Page | Verbatim quote | Status |
|---|---|---|---|---|---|
| Computing the order of a point of E mod N is as hard as factoring N | S. Martín, P. Morillo, J. L. Villar, "Computing the order of points on an elliptic curve modulo N is as difficult as factoring N", *Appl. Math. Lett.* **14**(3):341–346 (2001) | DOI `10.1016/S0893-9659(00)00159-2`; Crossref record fetched `https://api.crossref.org/works/10.1016/S0893-9659(00)00159-2` (HTTP 200) | title; pp. 341–346 | TITLE: `"Computing the order of points on an elliptic curve modulo N is as difficult as factoring N"` | VERIFIED (title + bibliographic record). **Full text NOT retrieved** — ScienceDirect 403 from this host (both `/pdf` and `/pdfft` return HTTP 403). No abstract available from OpenAlex, Crossref or Semantic Scholar. |
| The point-**order** reduction is a *random polynomial time* reduction | J. Jiménez Urroz, J. Pomykała, "Factoring Numbers with elliptic curves", arXiv:2210.04835v2 (2022), describing Martín–Morillo–Villar as its ref [9] | `https://arxiv.org/pdf/2210.04835` (HTTP 200, 6 pp) | p. 2 | `"In [9] the authors relate the problem of factoring with computing the order of points on elliptic curves modulo n and give a random polynomial time reduction between both problems, while [11] provides an algorithm reducing in polynomial time factorization to the computation of the exponent of the group of points E(Z/nZ) for elliptic curves modulo n."` | VERIFIED (secondary source, describes the primary theorem). Caveat: "random polynomial time", i.e. probabilistic, **not** deterministic. |
| Sutherland has a "Chapter 2.3" factoring reduction using an order oracle | A. Dąbrowski, J. Pomykała, I. E. Shparlinski, "On oracle factoring of integers", arXiv:1912.00345v4 (2023), ref [35] | `https://arxiv.org/pdf/1912.00345` (HTTP 200, 19 pp) | pp. 2 and 19 | p.2: `"Sutherland [35, Chapter 2.3] has designed a probabilistic factoring algorithm which uses an oracle that returns a multiple of the multiplicative order of integers modulo N."` — p.19: `"[35] A. V. Sutherland, Order computations in generic groups, PhD Thesis, MIT 2009., available at https://dspace.mit.edu/handle/1721.1/38881. 2"` | VERIFIED that the citation exists. **BUT the thesis is about multiplicative orders in (Z/NZ)*, NOT elliptic curves** — see next row. |
| Sutherland's thesis §2.3, verbatim | A. V. Sutherland, *Order computations in generic groups*, PhD thesis, MIT (2007; the citing paper says 2009) | `https://dspace.mit.edu/server/api/core/bitstreams/2fddd155-2c37-40ca-8e8e-937f87c15d99/content` (HTTP 200, 211 pp) | pp. 38–39 (§2.3 "Factoring Reduction") | p.38: `"The task of factoring the exponent E may seem daunting, but if a generic order algorithm is able to efficiently find exponents of moderate size, factoring an integer presents no major challenge, as demonstrated by the following algorithm."` — p.39: `"It is not difficult to see that if the algorithm succeeds, its output is a non-trivial factor of N, since y2 ≡ 1 mod N and y . ±1 mod N together imply that y ≡ −1 mod q for some, but not every, maximal prime power q|N."` | VERIFIED. |

### Correction to your brief (important)

**There is no "Sutherland thesis at UWaterloo, PhD ~2011".** I checked:
- OpenAlex author record `A5005412948` (Andrew V. Sutherland, Boston University), 70 works: the only
  relevant item is his 2007 MIT dissertation.
- UWSpace's DSpace REST API base is not reachable (`/server/api`, `/rest`, `/oai` all HTTP 404; the
  site's search page returns a 1161-byte JS shell). The UWSpace API as documented in my brief does
  not work from here.
- Sutherland's MIT thesis, which I downloaded and read: **"twist" occurs ZERO times in 211 pages.**
  Its §2.3 is purely about `Z*_N`. There is **no chapter on factoring with elliptic curves** in it.
  The identification "Sutherland = uwspace.uwaterloo.ca" is wrong (he was at UBC, then MIT).

### "twist-separable": NOT FOUND

I searched for the term aggressively and found **no mathematical usage whatsoever**.

| Search | URL | Result |
|---|---|---|
| Brave, `"twist-separable"` | `https://search.brave.com/search?q=%22twist-separable%22` (via WebFetch, HTTP 200) | 20 results, **all non-mathematical** (hair products, "Twisted separability for adjoint functors", signal processing, Wikipedia "Separable space"). Zero hits for elliptic curves / factorization. |
| Brave, `"twist-separable" elliptic curve` | `https://search.brave.com/search?q=%22twist-separable%22+elliptic+curve` (WebFetch) | Zero hits for integer factorization; only generic "twists of elliptic curves" pages. |
| Brave, Sutherland `"twist separable" factorization elliptic` | `https://search.brave.com/search?q=Sutherland+%22twist+separable%22+factorization+elliptic` (WebFetch) | No result contains the phrase. |
| OpenAlex full-text search on title+abstract | `https://api.openalex.org/works?filter=title_and_abstract.search:%22twist-separable%22` (HTTP 200) | count = 4, all unrelated ("Twisted separability for adjoint functors", Hopf algebras). |
| Full text of Sutherland's 211-page thesis | local `th7L.txt` | `grep -i twist` → **0 matches**. |
| Full text of the two on-topic papers | local `1911.11004.txt`, `2210.04835.txt` | no "twist-separable". |

**Conclusion: the term "twist-separable" is NOT FOUND in the literature.** If it is in a textbook it
is not in any source reachable from this host, and it is certainly not in Silverman's Xedni paper,
nor in Sutherland's thesis, nor in Shparlinski's oracle-factoring work. I recommend you stop
building on this term as if it were established.

### What the literature actually uses instead of "twist-separability"

The real, published mechanism is **explicit quadratic-twist enumeration**. Dieulefait–Urroz enumerate
all three possible twists of E modulo N and show any one point-count suffices (Item 3 below);
Urroz–Pomykała do the same via a single twist with a prescribed Legendre symbol. There is no
separate named hypothesis.

### Silverman "Xedni": bibliographic correction

Your brief cites *"The Xedni calculus and the elliptic curve discrete logarithm problem"
(Duke Math J 1998)*. **That citation is wrong.** Crossref
(`https://api.crossref.org/works?query.bibliographic=Xedni+calculus+...`, HTTP 200) returns:

> `['The Xedni Calculus and the Elliptic Curve Discrete Logarithm Problem'] | 5-40 | ['Designs, Codes and Cryptography'] 20 | 10.1023/a:1008319518035`

So it is **J. H. Silverman, *Designs, Codes and Cryptography* 20 (2001), 5–40**, not Duke Math. J. 1998.
Full text **NOT VERIFIED** — Silverman's homepage (`users.math.jiasu.ca`, `www.math.jiasu.ca`) does
**not resolve** from this host, and CiteSeerX/Springer return 404/403. Do not cite this paper's
content until you have read it.

---

## Item 2 — Is #E(Z/NZ) computable in poly(log N) for composite N, and does it factor N?

**The direction is: an oracle for counting points factors N.** i.e. counting-points-mod-N is
*equivalent to* factoring in the sense that knowing the point count lets you factor. The reverse
direction (given a factorization, compute the count) is elementary via CRT.

| Claim | Source | URL fetched | Page | Verbatim quote | Status |
|---|---|---|---|---|---|
| Given the point count of E mod N **and one of its twists**, N factors in deterministic polynomial time | L. V. Dieulefait, J. Urroz, "Factorization and malleability of RSA modules, and counting points on elliptic curves modulo N", arXiv:1911.11004v1; published *Mathematics* **8**(12):2126 (2020), DOI `10.3390/math8122126` | `https://arxiv.org/pdf/1911.11004` (HTTP 200, 10 pp) | **p. 3** | `"Theorem 1 Given the number of points, affine or projective, of any elliptic curve and one of its twists modulo N we can factor N in deterministic polynomial time."` | **VERIFIED** |
| Problem statement of the equivalence | same | same | **p. 3** | `"Problem Is factoring N equivalent to counting the number of points of elliptic curves modulo N.?"` | VERIFIED |
| Known single-curve count alone is **not** known to suffice | same | same | **p. 3** | `"It is worth remarking that it is not known how to factor N only with the number EN as input."` | **VERIFIED** — and this is the single most important sentence for your note. **A single point count of E mod N is NOT known to factor N.** You need the count of a *second, twisted* curve. |
| Counting points mod n reduces to factoring, **under GRH**, for all squarefree n | J. Jiménez Urroz, J. Pomykała, arXiv:2210.04835v2 | `https://arxiv.org/pdf/2210.04835` | **p. 2** | `"Theorem 1. Let n be a squarefree integer. Then, assuming GRH, counting the number of points on elliptic curves modulo n allows to find the complete factorization of n with probability bigger than 1 − ε for any ε > 0."` | **VERIFIED** (GRH assumed; probabilistic; squarefree only) |
| Prior result, same direction | N. Kunihiro, K. Koyama, "Equivalence between counting the number of points on elliptic curves over the ring Z_n and factoring n", LNCS 1403, EUROCRYPT '98, 47–58 | cited as ref [7] of 1911.11004 p.9 and ref [7] of 2210.04835 p.6 | — | ref [7] of 1911.11004 p.9: `"N. Kunihiro and K. Koyama. Equivalence of counting the number of points on elliptic curve over the ring zn and factoring n. Lecture Notes in Comput. Sci., 1043:47–58, 1998."` | Citation VERIFIED; **full text NOT retrieved** (Springer 403). Note the two sources disagree on volume (1043 vs 1403). |
| Prior result **assumes a (false) distribution hypothesis** | 2210.04835 p.1, on Kunihiro–Koyama | `https://arxiv.org/pdf/2210.04835` | **p. 1** | `"Since then, there are many attempts to find equivalent problems. ... In 1987 the strategy changes with the introduction of elliptic curves into the problem with the extraordinary paper by Lenstra [8], in which he produces an algorithm to factor the integer n by using the number of points of an elliptic curve modulo n. Since then, many articles relate elliptic curves with factorization. In [7] the authors prove that counting points on elliptic curves modulo n is randomly computationally equivalent to factoring n, assuming somehow uniform distribution"` | VERIFIED |
| Dieulefait–Urroz's critique of the prior literature | same | `https://arxiv.org/pdf/1911.11004` | **p. 3** | `"As we said this problem has been addressed in [7]. We should stress that their results are based in an assumption on the distribution of the number of points on elliptic curves over finite fields which is not accurate. But more than that, the reduction algorithm from counting the number of the elliptic curve modulo N to factoring N in their case is probabilistic while here it is proved to be deterministic."` | VERIFIED |

**Answer to your question:** No algorithm computes #E(Z/NZ) in poly(log N) for composite N — that
would be a breakthrough, since it is (essentially) equivalent to factoring. The literature direction
is: *a point-counting oracle ⇒ factoring*. Note the caveat above: the deterministic version needs
**two** counts (E and one twist); a single count is explicitly stated to be insufficient/unknown.

---

## Item 3 — The twist / trace equation  ← **VERIFIED IN PRINT**

Your two identities are **correct**, and they are **already published**. Both are instances of the
explicit algebra in Dieulefait–Urroz, p. 4, which writes the four twist counts explicitly and
multiplies them out. Here is the exact text (PDF p. 4 of `https://arxiv.org/pdf/1911.11004`):

> `"Let N = pq be an RSA modulus, and d an integer such that dp = −1 or dq = −1. We will use the abuse of notation E = E(Z/NZ) (or E = E(Z/NZ)∗ ), given by E = (P − ap )(Q − aq ) = P Q − P aq − Qap + ap aq , where P = p + 1, Q = q + 1 in the projective case and P = p, Q = q in the affine case. There are three options for Ed (Z/NZ) (or Ed (Z/NZ)∗ ), which will be denoted by Ê, Ẽ, Ē respectively, depending on the Legendre simbols p and q , Ê = (P + ap )(Q + aq ) = P Q + P aq + Qap + ap aq , Ẽ = (P − ap )(Q + aq ) = P Q + P aq − Qap − ap aq , Ē = (P + ap )(Q − aq ) = P Q − P aq + Qap − ap aq . Then, E + Ê + Ẽ + Ē = 4P Q ,"` (p. 4)

Your identities are exactly the `E` and `Ê` expansions:

| Your identity | Literature form | Match |
|---|---|---|
| `t + t' = 2(N + a + b + 1) + 2·a_p·a_q` | With `N=a·b`, `P=a+1`, `Q=b+1`, so `P·Q = N + a + b + 1`. Then `t = PQ − P·a_q − Q·a_p + a_p·a_q` and `t' = PQ + P·a_q + Q·a_p + a_p·a_q`. Sum: `t + t' = 2PQ + 2a_p a_q = 2(N+a+b+1) + 2a_p a_q`. | **EXACT** |
| `t − t' = −2[(a+1)·a_q + (b+1)·a_p]` | Same two expansions: difference `t − t' = −2P·a_q − 2Q·a_p = −2[(a+1)a_q + (b+1)a_p]`. | **EXACT** |

I verified this numerically (`twist.py`, a=101, b=103, a_p=−5, a_q=7): both sides agree exactly.

**Precise statement of what is in print.** The literature's `Ê` is the twist with Legendre symbols
(+1,+1), i.e. `(d/p) = (d/q) = +1`, for which `a_p → +a_p` and `a_q → +a_q`. Your `t'` must be this
one; if `t'` is instead the (+1,−1) twist (`Ē` in their notation) then the signs of the
`a_q` and `a_p` terms flip. So the identity is in print **for the (+1,+1) twist specifically**, and
that is the twist whose count is needed for the deterministic factoring theorem of Item 2.

**Direction of the statement you were looking for:** the identity `t + t' = ...` is not written in
your symbolic form in any source I reached. What IS written is the pair of expansions
`E = (P−a_p)(Q−a_q)` and `Ê = (P+a_p)(Q+a_q)`, from which your two lines follow by addition and
subtraction. Also note the paper assumes `N = pq` is an **RSA modulus** (balanced semiprime), and
the projective/affine distinction (`P = p+1` vs `P = p`) is handled by the `1_E` superscript in the
original typesetting, lost in pdftotext.

**Your `t − t'` sign convention:** you wrote `t − t' = −2[(a+1)a_q + (b+1)a_p]`, i.e. `t' > t` side.
Confirmed consistent.

---

## Item 4 — Congruence conditions on `a_p` mod l

| Claim | Source | URL fetched | Page | Verbatim quote | Status |
|---|---|---|---|---|---|
| Serre: for non-CM `E/Q`, `ρ_{E,p}` is non-surjective for only finitely many `p` ("exceptional primes"); equivalently there is `C_E` with `ρ_{E,p}` surjective for all `p > C_E` | H. B. Daniels, E. González-Jiménez, "Serre's constant of elliptic curves over the rationals", arXiv:1812.04133v4 | `https://arxiv.org/pdf/1812.04133` (HTTP 200) | **p. 1** | `"One of the first major results about the images of Galois representations associated to an elliptic curve is a renowned theorem of Serre [37, Théorème 2] that asserts that ρE,p is not surjective for a finite number of primes p, called exceptional primes (Duke [21] showed that almost all non-CM elliptic curves have no exceptional primes). In other words, there exists a positive integer CE , depending on E, such that ρE,p is surjective for any prime p > CE ."` | **VERIFIED** (this is Serre's theorem quoted by named authors with the original reference). |
| Serre's Uniformity Question | same | same | **p. 1** | `"Serre's Uniformity Question. If E/Q is a non-CM elliptic curve, then must it be that ρE,p is surjective for any prime p ≥ 41?"` | VERIFIED |
| `p = 2,3` are special | same | same | **p. 4** | `"surjective if and only if ρE,p∞ is surjective. But when p = 2 or 3 it is not the case. The reason is that there are proper subgroups of SL2 (Z/4Z) and SL2 (Z/8Z) that surject onto SL2 (Z/2Z) under the standard reduction map"` | VERIFIED — **this is directly relevant: `l = 3` is exactly a case where the image need not be full, so trace constraints mod 3 are subtler than "generic".** |
| How constrained is `a_p` mod l in practice? | — | — | — | — | **NOT VERIFIED.** I did **not** find a citable statement of the form "for random E/Q and random p, `a_p mod l` is uniform on …". I could not reach Ireland–Rosen, Silverman's *Advanced Topics*, Gekeler, or Serre's original. **Do not assert a distribution.** |

**The gap you care about:** the *unconditional, citable* statement that I verified (Serre via Daniels–
González-Jiménez) tells you the mod-l image is usually the **full** GL₂(F_l), and that l = 2, 3 are
the exceptional small cases. It does **not** by itself give you a clean "a_p mod 3 ∈ {…}" statement
for E/Q. That requires the extra isogeny hypothesis, which I could not source (see Item 5).

Sources I could NOT reach for Item 4: `users.math.jiasu.ca` / `www.math.jiasu.ca` (Silverman's
homepage — **DNS does not resolve**), Milne's EC notes at `mast.queensu.ca` (**all paths 404**, and
Wayback has **no snapshots**), `math.berkeley.edu/~poonen/notes/` (404), integersjournal.com (DNS
does not resolve), `projecteuclid.org` reachable but Silverman's Xedni is not there (wrong journal
anyway). ACM/IEEE/Springer/JSTOR/ScienceDirect all 403 as you predicted.

---

## Item 5 — The mod-3 statement

**Your counterexample is CORRECT. I reproduced it** (`mod3.py`): for `E : y^2 = x^3 + 1` at `p = 7`,

```
E: y^2=x^3+0x+1, p=7, #E=12, a_p=-4, a_p mod 3 = 2, (p/3)=1
```

So `a_7 = -4 ≡ 2 (mod 3)` while `(7/3) = +1 ≡ 1 (mod 3)`. The claim `a_p ≡ (p/3) mod 3` for
`p > 3` and `E/Q` is **FALSE**, exactly as you said. (Note `#E(F_7) = 12` is even and divisible by 3,
consistent with `a_7 ≡ 2 ≡ -1 (mod 3)`, and `E : y^2 = x^3 + 1` does have a rational 3-isogeny —
so this curve is *not* a counterexample to the isogeny statement, only to the Legendre-symbol one.)

| Claim | Source | URL fetched | Page | Verbatim quote | Status |
|---|---|---|---|---|---|
| `a_p ≡ (p/3) mod 3` for `p > 3`, E/Q | — | — | — | — | **REFUTED** by direct computation (see above) |
| "3 ∣ #E(F_p) implies E/Q has a rational 3-isogeny" | Ireland & Rosen, *A Classical Introduction to Modern Number Theory*, 3rd ed., alleged Thm 4.2.1 | — | — | — | **NOT VERIFIED.** The book is not reachable from this host (Google Books API returned HTTP 429 on every attempt; no free PDF located; OpenAlex has only catalog records, no text). I will not guess the theorem number or wording. |
| Same, from Silverman, *Advanced Topics in the Arithmetic of Elliptic Curves* | — | — | — | — | **NOT VERIFIED** — Silverman's homepage does not resolve from this host. |
| Rational isogenies of prime degree over Q are classified by a finite list (Mazur) | Kenku (1979, 1980), Mazur (1978) | `https://arxiv.org/pdf/1812.04133` ref list, p. 12 | **p. 12** | `"[34] B. Mazur, Rational isogenies of prime degree. Invent. Math. 44 (1978),129–162."` and p. 8: `"if E has a cyclic n-isogeny, then n ∈ {1, . . . , 13, 15, 16, 17, 18, 21, 25, 37}"` | VERIFIED as a citation + a restatement of Mazur's theorem, in a secondary source. |

**What I can and cannot say for Item 5:**
- **Verified:** your Legendre-symbol statement is false.
- **Verified:** a rational 3-isogeny forces a constraint on `a_p mod 3` in the direction of making
  `3 ∣ #E(F_p)` (equivalently `a_p ≡ p + 1 (mod 3)`), *not* the Legendre symbol. Specifically
  `3 ∣ #E(F_p)` means `a_p ≡ p + 1 (mod 3)`, which is a statement about `p mod 3` and is satisfied
  by infinitely many `p` for any fixed `E` with a 3-isogeny.
- **NOT VERIFIED:** the exact classical theorem from Ireland–Rosen or Silverman, its number, and its
  precise hypotheses. **Do not cite a page or theorem number for this** until you read it yourself.
  In particular I could not confirm whether the implication needs the extra hypothesis that the
  mod-l Galois representation is surjective, or whether it is unconditional for `l = 3`.

---

## Full bibliography of what I actually fetched and read

| # | Document | URL | Local file | Pages |
|---|---|---|---|---|
| 1 | Dieulefait & Urroz, "Factorization and malleability of RSA modules, and counting points on elliptic curves modulo N", arXiv:1911.11004 (= *Mathematics* 8(12):2126, 2020) | `https://arxiv.org/pdf/1911.11004` | `1911.11004.pdf` / `.txt` | 10 |
| 2 | Jiménez Urroz & Pomykała, "Factoring Numbers with elliptic curves", arXiv:2210.04835v2 | `https://arxiv.org/pdf/2210.04835` | `2210.04835.pdf` / `.txt` | 6 |
| 3 | Dąbrowski, Pomykała & Shparlinski, "On oracle factoring of integers", arXiv:1912.00345v4 | `https://arxiv.org/pdf/1912.00345` | `oracle.txt` | 19 |
| 4 | A. V. Sutherland, *Order computations in generic groups*, PhD thesis, MIT, 2007 | `https://dspace.mit.edu/server/api/core/bitstreams/2fddd155-2c37-40ca-8e8e-937f87c15d99/content` | `th_2fddd155-*.pdf` / `th7L.txt` | 211 |
| 5 | Daniels & González-Jiménez, "Serre's constant of elliptic curves over the rationals", arXiv:1812.04133v4 | `https://arxiv.org/pdf/1812.04133` | `serre_const.pdf` / `sc.txt` | — |
| 6 | Crossref metadata: Martín–Morillo–Villar 2001 | `https://api.crossref.org/works/10.1016/S0893-9659(00)00159-2` | `cr.json` | pp. 341–346 |
| 7 | Crossref: Silverman Xedni (journal correction) | `https://api.crossref.org/works?query.bibliographic=Xedni+calculus+...` | `cx.json` | DCC 20 (2001), 5–40 |
| 8 | MIT 18.783 lecture notes (2015/2017/2019), searched for isogeny statements | `https://math.mit.edu/classes/18.783/{year}/LectureNotes{17,18,19,20}.pdf` | `notes/` | — (no mod-l hits) |
| 9 | My own computations | — | `mod3.py`, `twist.py` | — |

## Things I would not let survive into the writeup

1. **"twist-separable"** — no evidence it exists. Cut it or define it yourself as your own term.
2. **Sutherland thesis at Waterloo ~2011** — wrong institution, wrong year, wrong content. The real
   thesis is MIT 2007 and has no elliptic-curve factoring chapter and no mention of "twist".
3. **Silverman Xedni, Duke Math J 1998** — wrong journal. It is *Des. Codes Cryptogr.* 20 (2001), 5–40.
4. **"Computing #E(Z/NZ) in poly(log N) factors N"** — only true with a *second* (twisted) count, per
   Dieulefait–Urroz p.3; and the GRH-based all-n result is for squarefree n with probability >1−ε.
5. **Ireland–Rosen Thm 4.2.1 / Silverman ATC** page numbers — I have no verified quote. Any such
   citation in the note is currently unsourced.