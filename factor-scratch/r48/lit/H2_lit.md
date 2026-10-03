# H2 — Literature verification: PROVABLE smoothness guarantees in structured settings

Date of verification: 2026-10-03. Working dir: `/home/raver1975/lean/factor-scratch/r48/lit/`.

**Method / routes that worked from this host** (for reproducibility):
- `export.arxiv.org/api/query` returns **HTTP 429** persistently — unusable.
- arXiv **search UI** works: `curl -sSL -A "Mozilla/5.0 (X11; Linux x86_64)" "https://arxiv.org/search/?searchtype=all&query=..."`. Note it is an **OR** match, so unquoted multi-word queries return noise; quoted phrases work.
- `https://arxiv.org/abs/ID` and `https://arxiv.org/pdf/ID` work with the same UA; `pdftotext` is installed and used for full-text quotes.
- **zbmath.org: 403** (Cloudflare). **HAL (hal.science): returns a JS shell, not the document.** **api.semanticscholar.org: 429.**
- **numdam.org WORKS** and is the route for pre-1990 primary sources (used for Balog).

**Correction to the task brief (both verified):**
1. Balog's smooth-numbers-in-short-intervals paper is **not** in Acta Math. Hungar and **not** titled "On the distribution of p-integers". It is *Astérisque* **147–148 (1987), 27–31**, "On the distribution of integers having no large prime factor". Verified on the Numdam scan.
2. The Hildebrand/Tenenbaum item "Integers without large prime factors **in short intervals**" (1986) exists but the journal record is: Hildebrand & Tenenbaum, "On integers free of large prime factors", **Trans. Amer. Math. Soc. 296 (1986), no. 1, 265–290**. (Younis's bibliography `[HT86]`.) The 1993 survey is a *different* paper.

---

## A. Balog — y-smooth numbers in short intervals

### A1. Balog 1987 (PRIMARY, full text scanned and fetched)
- **Status:** FOUND
- **URL:** `https://www.numdam.org/item/AST_1987__147-148__27_0/` (landing, 200) and `http://www.numdam.org/item/AST_1987__147-148__27_0.pdf` (PDF, 403132 bytes, 6 pages)
- **Verbatim (title block, Numdam scan header):**
  > "On the distribution of integers having no large prime factor / Astérisque, tome 147-148 (1987), p. 27-31 / Société Mathématique de France"
- **Verbatim (§1, framing of the problem — Friedlander–Lagarias function f(a)):**
  > "Friedlander and Lagarias [2] considered the problem of estimating the number $$ (X,Z,Y) of integers in the interval (X-Y,X] having no prime factor >Z . Especially they defined f(a) as the infimum of the values of 0 for which for all a'>a one had"
- **Verbatim (§2, the short-interval conclusion — OCR of the scanned original):**
  > "For a given e>0 and 0<a^1 we can choose a k>max {...} and, am = [...] if m has no prime factor > X^a. Our lemma, then, guarantees that the interval (X-X^y/2 + e rx] contains numbers n in the form n = 5,m1m2 where m. has no prime factor > X^a"
- **Note:** the exact exponent relation is *not* legibly recoverable from the 1987 scan — the fraction glyphs are mangled in the scanned/OCR'd original (`X^y/2 + e rx` is a garbled rendering of `x^{1/2+ε}`). **Do not quote the Balog exponent from this scan.** Use A2 below, which is a clean secondary statement of the same theorem.

### A2. Balog's theorem as stated in Soundararajan (arXiv:1009.1591) — the usable form
- **Status:** FOUND
- **URL:** `https://arxiv.org/pdf/1009.1591` (PDF), abs page `https://arxiv.org/abs/1009.1591`
- **Section:** Introduction, paragraph beginning "Regarding this problem…"
- **Verbatim:**
  > "Regarding this problem, an important advance was made by Balog [1] who showed 1 that for any fixed ǫ > 0 and x large, the interval [x, x+x 2 +ǫ ] contains many xǫ -smooth integers. Harman [7] has obtained a strengthening of this √ result, allowing ǫ to be a function of x."
- **Note:** **h = x^{1/2+ε} guarantees an x^ε-smooth number in [x, x+h]**, unconditionally. The square root in the interval length is the important number: provable smoothness reaches y = x^ε at interval length x^{1/2+ε}.

### A3. Soundararajan 2010 (RH-conditional) — `https://arxiv.org/abs/1009.1591`
- **Status:** FOUND
- **Abstract, verbatim:**
  > "Abstract: Assuming the Riemann hypothesis we demonstrate the existence of smooth numbers in certain short intervals."
- **Main Theorem (from `https://arxiv.org/pdf/1009.1591`, p.2), verbatim:**
  > "Theorem.√ Assume the Riemann Hypothesis. Let x be large and suppose that x ≥ 1 u y ≥ exp(5 log x log √ log x), and write y = x . There is an absolute constant B such that with z = Bu x/ρ(u/2) we have Ψ(x + z, y) − Ψ(x, y) ≫ǫ zx−ǣ ."
- **Verbatim (the ECM motivation — the sentence that ties this whole topic to factoring):**
  > "One motivation for this problem is the analysis of Lenstra's elliptic curve factorization algorithm [11] (and see also [13]) where one wishes to find integers in [x, x + 4 x] which are exp( log x log log x) smooth."
- **Verbatim (the author explicitly says the result is still too weak for ECM):**
  > "We improve upon Xuan's work by establishing the following theorem, which unfortunately is still not strong enough to be applicable to the analysis of Lenstra's algorithm."
- **Verbatim (the heuristic target — shows the provable/heuristic gulf):**
  > "one would expect that for every ǫ > 0 there exists a constant C(ǫ) such that every interval [x, x + C(ǫ) log x] contains an xǫ -smooth number. This would be analogous to Cramér's conjecture on the distribution of prime numbers"
- **Note:** **This is the single best "provable vs expected" statement in the whole file.** Provable (RH): y ≈ x^{1/u}, interval length z = B·u·x^{1/2}/ρ(u/2) ≈ x^{1/2+o(1)}. Heuristic target: interval length only **log x**. The gap between the provable x^{1/2} and the expected (log x) is ~2 orders of magnitude in the exponent.

### A4. References verified as citations from Soundararajan's bibliography (`https://arxiv.org/pdf/1009.1591`, References)
- **Verbatim:**
  > "[1] A. Balog, On the distribution of integers having no large prime factors, Astérisque., 147-148 (1987), 27-31." / "[7] G. Harman, Short intervals containing numbers without large prime factors, Math. Proc. Cambridege Philos. Soc., 109 no: 1 (1991), 1-5." / "[8] G. Harman, Integers without large prime factors in short intervals and arithmetic progressions, Acta Arith. XCL. 3 (1999), 279–289."
- **Note:** these are citation records (as printed in a peer-reviewed preprint), not independently fetched papers. Balog's is independently confirmed by the Numdam scan (A1).

### A5. Balog–Wooley
- **Status:** **COULD NOT FETCH** — arXiv search returned no results for `au:"Balog" AND au:"Wooley" AND abs:"smooth"`; zbMATH is Cloudflare-403. No claim made.

### A6. Friedlander–Iwaniec on smooth numbers in short intervals
- **Status:** **COULD NOT FETCH** — arXiv search `au:"Friedlander" AND au:"Iwaniec" AND abs:"smooth"` returned no results; zbMATH 403. (The related Friedlander–**Granville** 1993 paper is documented at C3 via a verified secondary source.) No claim made.

---

## B. Hildebrand 1986 (short intervals) and the AP result

### B1. Hildebrand 1986 — exact range, via Younis 2024
- **Status:** FOUND (secondary; the 1986 paper itself is J. Number Theory, not on arXiv/numdam)
- **URL:** `https://arxiv.org/pdf/2409.05761`
- **Section:** §1 Introduction, discussion of (1.1)
- **Verbatim:**
  > "By first counting numbers with a single very large prime factor and then employing a 'recursive identity' for the set of smooth numbers, the first result establishing a relation of the form (1.1) was by Hildebrand [Hil86] on the range x/y 5/12 ≤ h ≤ x 5/3+ε e(log log x) and ≤ y ≤ x."
- **Verbatim (immediately following — the obstruction and the open direction):**
  > "The restriction on h stems from the well-known estimates of Huxley on the prime number theorem in short intervals, and the y bound comes from an application of the best known error terms in the prime number theorem. It has been suggested, for instance in [FG93], [HT93, §5], and [Gra08, §4], that ideas of Granville [Gra93] may enable the 5/12 to be improved to 1 − ε."
- **Verbatim (why h = x^θ fixed was out of reach of Hildebrand):**
  > "Returning to asymptotic results, suppose we wanted the short interval to be rather small, say h = xθ for some fixed 0 < θ < 1. We see that the results of Hildebrand, and of Hildebrand and Tenenbaum, stated earlier oﬀer nothing in this scenario."
- **Bibliography entry, verbatim:**
  > "[Hil86] A. Hildebrand, On the number of positive integers ≤ x and free of prime factors > y, J. Number Theory 22 (1986), no. 3, 289–307."
- **Note:** Hildebrand 1986 covers **h ≥ x^{5/3+ε}/(log log x)^5** — i.e. intervals *much longer than* x^{1/2}. It is an **asymptotic** result, not an existence guarantee, and does **not** reach h = x^{1/2}. (The task brief's title "…free of prime factors > y **in arithmetic progressions**" does not match this 1986 J. Number Theory paper; that title belongs to a different item.)

### B2. Fouvry–Tenenbaum 1991 (smooth numbers in arithmetic progressions) — citation record
- **Status:** FOUND as citation only (source not fetched)
- **URL:** `https://arxiv.org/pdf/2409.05761` (Younis bibliography)
- **Verbatim:**
  > "[FT91] É. Fouvry and G. Tenenbaum, Entiers sans grand facteur premier en progressions arithmetiques, Proc. London Math. Soc. (3) 63 (1991), no. 3, 449–494."
- **Note:** the AP analogue of Hildebrand. **The 1991 primary text was not fetched** — no statement quoted. Flagged as an unread target.

---

## C. Hildebrand & Tenenbaum — smooth numbers in short intervals

### C1. H&T 1986 — exact range, via Younis 2024
- **Status:** FOUND (secondary)
- **URL:** `https://arxiv.org/pdf/2409.05761`
- **Verbatim:**
  > "Hildebrand and Tenenbaum [HT86] later proved an asymptotic of the shape (1.1) (though with the right-hand side multiplied by a positive quantity α = α(x, y) known as the saddle point, which we deﬁne later) valid in a wide range of y (which is slightly more tricky to state) and for which it is necessary, but not suﬃcient, to have x/e(log x) 3/5 1 ≤ h ≤ x."
- **Bibliography entry, verbatim:**
  > "[HT86] A. Hildebrand and G. Tenenbaum, On integers free of large prime factors, Trans. Amer. Math. Soc. 296 (1986), no. 1, 265–290." / "[HT93] , Integers without large prime factors, J. Théor. Nombres Bordeaux 5 (1993), no. 2, 411–484."
- **Note:** answer to the brief's question "when does [x, x+x^{1/2+ε}] contain a y-smooth number" **for H&T 1986: it does not.** H&T's h-range starts at x^{3/5}/(log x) and their result is an asymptotic with a saddle-point main term, not an existence statement.

### C2. Jain 2025 — the current best all-intervals existence result, and its explicit comparison to H&T
- **Status:** FOUND (primary)
- **URL:** `https://arxiv.org/abs/2502.10530`, PDF `https://arxiv.org/pdf/2502.10530`
- **Abstract, verbatim:**
  > "Let \( X \geq y \geq 2 \), and let \( u = \frac{\log X}{\log y} \). We say a number is $y$-smooth if all of its prime factors are less than or equal to \( y \). In this paper, we study the distribution of $y$-smooth numbers in short intervals. In particular, for \( y \geq \exp\left( (\log X)^{2/3 + \epsilon} \right) \), we show that the interval \( [x, x+h] \) contains a $y$-smooth number for almost all \( x \in [X, 2X] \), provided \( h \geq \exp\left( (1 + \epsilon) \left( \frac{11}{8} u \log u + 4 \log \log X \right) \right) \), and \( X \) is sufficiently large depending on \( \epsilon \)."
- **Theorem 1.2 (all intervals — the key existence bound), verbatim from PDF p.2:**
  > "Theorem 1.2. For any ε > 0, there exists a positive constant C = C(ε) such that the following holds. If x is large in terms of ε, exp C(log x)2/3 (log log x)4/3 ≤ y ≤ x C , and h≥ x exp (1 + ε) 11 16 u e log u e + 2 log log x , where u e = log x log y , then the interval [x, x + h] contains a y-smooth number."
- **Verbatim (§1, the H&T comparison, directly answering the brief's question about H&T's intervals):**
  > "For example, Hildebrand and Tenenbaum [6] proved an asymptotic formula for the number of smooth numbers in almost all short intervals. However, the intervals they consider are signiﬁcantly longer than those considered here. Building on their work, Granville and Friedlander [2] obtained the corresponding “all intervals” type result."
- **Verbatim (§1, the historical baseline — Matomäki–Radziwiłł's unconditional square-root guarantee):**
  > "In a breakthrough paper, Matomäki and Radziwill showed that such a result holds for almost all x ∈ [X, 2X], at least when y = X 1/u and h = ψ(X) (see [9, Corollary 6]). In the same paper, they also showed that, for every ε > 0, there exists a suﬃciently large constant √ Cε > 0 such that every interval [x, x + h] contains an xε -smooth number, provided h ≥ Cε x (see [9, Corollary 1])."
- **Verbatim (§1, the heuristic target Jain is measured against):**
  > "Since ρ(u) = uu+o(u) , based on probabilistic heuristics, one expects this to hold for almost all short intervals of size h ≥ exp ((1 + ε)u log u). However, this kind of result seems far out of reach."
- **Verbatim (§1.1, the mechanism — a *weighted* relaxation, not a pointwise guarantee):**
  > "Choose weights {wn }n such that wn ≥ 0 if n ∈ S(y) and P 0 otherwise. Let H be such that x≤n≤x+H wn > 0 for all x ∈ [X, 2X]. It turns out that, for our choice of weights, we can take H = Xy −3/8 (see Lemma 4.2 below)."
- **Note:** **Jain's Theorem 1.2 is the current best unconditional all-intervals existence result** and it lands at **h ≈ x^{1/2} exp((1+ε)·(11/16)·u log u)**, i.e. **square-root length plus a Dickman-function factor**, with y ≥ exp(C(log x)^{2/3}(log log x)^{4/3}). Compare the heuristic h ≈ x^{1/2+o(1)} and Soundararajan's hope of h ≈ log x. The 11/16 (Jain) vs 7/4 (Matomäki) vs 11/8 (Matomäki, a.e.) coefficients show the provable gap.

### C3. Younis 2024 — the strongest **asymptotic** short-interval result
- **Status:** FOUND (primary)
- **URL:** `https://arxiv.org/abs/2409.05761`, PDF `https://arxiv.org/pdf/2409.05761`
- **Abstract, verbatim:**
  > "Abstract. A number is said to be $y$-smooth if all of its prime factors are less than or equal to $y.$ For all $17/30<\theta\leq 1,$ we show that the density of $y$-smooth numbers in the short interval $[x,x+x^{\theta}]$ is asymptotically equal to the density of $y$-smooth numbers in the long interval $[1,x],$ for all $y \geq \exp((\log x)^{2/3+\varepsilon}).$ Assuming the Riemann Hypothesis, we also prove that for all $1/2<\theta\leq 1$ there exists a large constant $K$ such that the expected asymptotic result holds for $y\geq (\log x)^{K}.$"
- **Verbatim (Friedlander–Granville 1993 range — the "all intervals" result built on H&T):**
  > "Friedlander and Granville [FG93] later showed, by exploiting an 'almost-all' result for smooth numbers, the asymptotic (1.1) holds in the range √ 2 (log x)1/6 5/6+ε xy e ≤ h ≤ x and e(log x) ≤ y ≤ x."
- **Verbatim (why 17/30 — the exponent is inherited from the PRIME number theorem, not from smoothness):**
  > "The exponent (30 + ε)/13 in (1.13) was obtained in recent breakthrough work of Guth and Maynard [GM24], leading to θ > 17/30 being permissible. This improved the long-standing exponent of (12 + ε)/5 due to Huxley [Hux72] which allowed θ > 7/12, as well as a result of Heath-Brown [HB88] allowing θ = 7/12 − o(1)."
- **Note — the key structural finding for the report:** **the short-interval length barrier θ > 17/30 is inherited wholesale from the prime number theorem in short intervals (Guth–Maynard), not from any smoothness difficulty.** This is the mechanism by which smoothness results get stuck at θ ≈ 1/2–0.57.

### C4. The existential (lower bound) chain, verbatim, from `https://arxiv.org/pdf/2409.05761` §1
- **Verbatim:**
  > "The breakthrough work of Matomäki and Radziwi √ ll on multiplicative functions in short intervals [MR16] showed that there are at least x/(log x)4 many y-smooth numbers for y = xε and h = C(ε) √ x. Matomäki [Mat16] showed that for y = e(log x) 2/3 (log log x)4/3+ε and h = x1/2−ε a lower bound of magnitude x1/2−ε is attainable. Earlier work of Xuan [Xua99] demonstrated the existence of such smooth numbers in essentially this regime."
- **Verbatim (the RH-conditional optimum):**
  > "Conditional √ on the Riemann Hypothesis, Soundararajan [Sou10] proved that one may take y = e5 log x log log x and h = x1/2+o(1) , also for a lower bound of magnitude x1/2−ε . These works explicitly describe their o(1) terms."

**Summary of the provable existence frontier (all from fetched quotes):**

| Result | Interval length h | Smoothness y | Assumption |
|---|---|---|---|
| Balog 1987 | x^{1/2+ε} | x^ε | unconditional |
| Matomäki–Radziwiłł 2016 | C_ε·x^{1/2} | x^ε | unconditional |
| Xuan 1999 | x^{1/2}(log x)^{1+ε} | x^ε | **RH** |
| Soundararajan 2010 | x^{1/2+o(1)} | exp(5√(log x log log x)) | **RH** |
| Matomäki 2016 | x^{1/2−ε} | exp((log x)^{2/3+ε}) | unconditional |
| **Jain 2025 (best unconditional all-intervals)** | x^{1/2}exp((1+ε)(11/16)u log u) | exp(C(log x)^{2/3}(log log x)^{4/3}) | unconditional |
| *heuristic target* | **log x** | x^ε | — |

---

## D. Smooth values of POLYNOMIALS

### D1. Bober–Fretwell–Martin–Wooley, "Smooth values of polynomials" — the key primary source
- **Status:** FOUND (primary, full PDF)
- **URL:** `https://arxiv.org/pdf/1710.01970`, abs `https://arxiv.org/abs/1710.01970`
- **Abstract, verbatim:**
  > "Abstract. Given f ∈ Z[t] of positive degree, we investigate the existence of auxiliary polynomials g ∈ Z[t] for which f (g(t)) factors as a product of polynomials of small relative degree. One consequence of this work shows that for any quadratic polynomial f ∈ Z[t] and any ε > 0, there are infinitely many n ∈ N for which the largest prime factor of f (n) is no larger than nε ."
- **Theorem 1.1, verbatim:**
  > "Theorem 1.1. Let f ∈ Z[t] be quadratic. Then for some c > 0 there are polynomials g ∈ Z[t] of arbitrarily large odd degree √ k for which f (g(t)) factors as a product of polynomials of degree at most ck/ log log k. Thus f admits polysmoothness ε for any ε > 0."
- **Corollary 1.2 — THE headline provable statement, verbatim:**
  > "Corollary 1.2. When ε > 0 and f ∈ Z[t] is quadratic, there are infinitely many n ∈ N for which f (n) is nε -smooth. Thus f admits smoothness ε."
- **Verbatim (the prior best, and its numerical value — 0.2795 is the old barrier):**
  > "The sharpest conclusion available for quadratic polynomials hitherto is due to Schinzel [9, Theorem 15]. This work, half a century old, shows that when f ∈ Z[t] is quadratic, then it admits smoothness θ, where θ = 1− 1/2 · 1/3 · 1/7 · 1/47 · 1/2207 · · · = 0.27950849 . . . ."
- **Verbatim (Schinzel's special-case result and the explicit unsolved example):**
  > "Schinzel [9, Theorem 14] shows that if f (t) = a(rt + s)2 ± b, with a, r, s ∈ Z, ar 6= 0 and b ∈ {1, 2, 4}, then f admits smoothness ε for any ε > 0. However, as is implict in the concluding remarks of Schinzel [9], polynomials such as 4t2 + 4t + 9 = (2t + 1)2 + 8 remain inaccessible to these methods."
- **Verbatim (degree ≥ 3 — still far from ε, i.e. the barrier does NOT move above degree 2):**
  > "The state of knowledge for polynomials of degree exceeding 2 is in general far less satisfactory."
- **Verbatim (§1, the degree-d exponents — θ(3) = 0.38, θ(4) = 0.56):**
  > "Then Schinzel [9, Theorem 15] shows that every polynomial f ∈ Z[t] of degree d admits polysmoothness θ(d)." / "θ(2) = 0.27950849 . . . , θ(3) = 0.38188130 . . . , θ(4) = 0.55901699 . . . , and that for large d one has θ(d) = 1 − 1/d + O(1/d3)"
- **Verbatim (the conjecture that would settle it):**
  > "Motivated by the widely held conjecture that for each ε > 0, every f ∈ Z[t] of positive degree should admit smoothness ε, the latter considerations prompt the following question."
- **Verbatim (Corollary 1.4, relevant to the x²+y³ shape via composition):**
  > "Corollary 1.4. Suppose that f ∈ Z[t] is irreducible, and let α be a root of f lying in its splitting field. Suppose that f (t) = g(h(t)) − t, with g, h ∈ Z[t] of degree exceeding 1. Then f (g(t)) is divisible by the minimal polynomial of h(α) over Q, and hence f admits polysmoothness 1 − 1/deg(g)."
- **Verbatim (worked example):**
  > "the polynomial f (t) = t4 + 4t2 − t + 1 satisfies the relation f (t) = (t2 + 1)2 + 2(t2 + 1) − t − 2 = g(h(t)) − t , with g(t) = t2 + 2t − 2 and h(t) = t2 + 1."
- **Note:** **this is the strongest provable "smooth polynomial values" statement I could fetch.** It is a *single-variable* result (infinitely many n with P(f(n)) ≤ n^ε, for **quadratic** f). It is **existence**, not density, and gives **no** statement about values in a prescribed interval [x, x+h] nor about a**two**-variable form f(a,b). Degree ≥ 3 remains at θ(3) ≈ 0.38.

### D2. Fouvry–Lacroix
- **Status:** **COULD NOT FETCH** — arXiv quoted-phrase search returned no relevant hit; zbMATH 403. No claim made.

### D3. van de Woestijne, "Smooth values of a polynomial"
- **Status:** **COULD NOT FETCH** — the paper appears in Bober et al.'s reference list only under the name "van de Woestijne" is *not* matched; Crossref query for that author returned only Benezit/Grove music-dictionary entries (a name collision), and no arXiv abstract page was located. No claim made. **Recommend a zbMATH-institutional-access follow-up.**

### D4. Two-variable smooth values (the actual a²−b³ question)
- **Status:** **COULD NOT FETCH / NO SOURCE FOUND.** arXiv quoted searches for `%22friable%20values%22` returned only unrelated items; `%22x%5E2%2By%5E3%22 AND abs:"smooth"` returned nothing. **I found no fetched source making a two-variable claim.** The nearest fetched result (D1, Corollary 1.4) is a **composition** statement about single-variable f(g(t)), which is *not* the same as a two-variable form f(a,b) — do not conflate them.

---

## E. Best provable UNCONDITIONAL deterministic factoring bound

### E1. Harvey & Hittmeir 2021 — the current best
- **Status:** FOUND (primary)
- **URL:** `https://arxiv.org/abs/2105.11105`, PDF `https://arxiv.org/pdf/2105.11105`
- **Abstract, verbatim (the sentence the brief asked for):**
  > "Abstract: Building on techniques recently introduced by the second author, and further developed by the first author, we show that a positive integer $N$ may be rigorously and deterministically factored into primes in at most \[ O\left( \frac{N^{1/5} \log^{16/5} N}{(\log\log N)^{3/5}}\right) \] bit operations. This improves on the previous best known result by a factor of $(\log \log N)^{3/5}$."
- **Theorem 1.1, verbatim from PDF p.2:**
  > "Theorem 1.1. There is a deterministic integer factorisation algorithm achieving F(N ) = O( N 1/5 log16/5 N / (log log N )3/5 )."
- **Verbatim (the mechanism — and note it is Lehman/rational approximation, NOT smoothness):**
  > "The strategy of [Har20] may be outlined as follows. Fix some integer α coprime to N . Since p ≡ 1 (mod p−1), Fermat's little theorem implies that αaq+bp ≡ αaN +b (mod p) for any a, b ∈ Z."
- **Verbatim (the new ingredient — restriction to candidates coprime to the primorial):**
  > "The new algorithm in this paper follows the same basic plan described above, but utilises the additional information that p and q cannot themselves be divisible by small primes. We modify the algorithm so that it restricts attention to candidates for p that are coprime to m := 2×3×5×· · ·×pd ≪ N 1/2 , i.e., m is the product of the first d primes for suitable d."
- **Note:** **F(N) = O(N^{1/5} log^{16/5} N / (log log N)^{3/5}) bit operations.** This is a **deterministic polynomial-exponential** bound (N^{1/5}), NOT subexponential. Crucially: **it does not go through smoothness at all** — it is Lehman rational approximation plus primorial sieving. Confirmed by grep: the string "smooth" **does not occur anywhere** in the paper.

### E2. Harvey 2020 — the N^{1/5} breakthrough
- **Status:** FOUND (primary)
- **URL:** `https://arxiv.org/abs/2010.05450`
- **Abstract, verbatim:**
  > "Abstract: Hittmeir recently presented a deterministic algorithm that provably computes the prime factorisation of a positive integer $N$ in $N^{2/9+o(1)}$ bit operations. Prior to this breakthrough, the best known complexity bound for this problem was $N^{1/4+o(1)}$, a result going back to the 1970s. In this paper we push Hittmeir's techniques further, obtaining a rigorous, deterministic factoring algorithm with complexity $N^{1/5+o(1)}$."

### E3. Hittmeir 2016 — the N^{2/9} breakthrough
- **Status:** FOUND (primary)
- **URL:** `https://arxiv.org/abs/1608.08766`
- **Abstract, verbatim:**
  > "Abstract: In 1977, Strassen presented a deterministic and rigorous algorithm for solving the problem of computing the prime factorization of natural numbers $N$. His method is based on fast polynomial arithmetic techniques and runs in time $\widetilde{O}(N^{1/4})$, which has been state of the art for the last forty years. In this paper, we will combine Strassen's approach with a babystep-giantstep method to improve the currently best known bound by a superpolynomial factor. The runtime complexity of our algorithm is of the form \[ \widetilde{O}\left(N^{1/4}\exp(-C\log N/\log\log N)\right). \]"
- **Note:** N^{1/4}exp(−C log N/log log N) is the first bound **below every fixed power** of N — but still exponential, not L_n[1/3, c].

### E4. Hittmeir 2020 — the 2/9 time-space tradeoff
- **Status:** FOUND (primary)
- **URL:** `https://arxiv.org/abs/2006.16729`
- **Abstract, verbatim:**
  > "Abstract: Fermat's well-known factorization algorithm is based on finding a representation of natural numbers $N$ as the difference of squares. In 1895, Lawrence generalized this idea and applied it to multiples $kN$ of the original number. A systematic approach to choose suitable values for $k$ was introduced by Lehman in 1974, which resulted in the first deterministic factorization algorithm considerably faster than trial division. In this paper, we construct a time-space tradeoff for Lawrence's generalization and apply it together with Lehman's result to obtain a deterministic integer factorization algorithm with runtime complexity $O(N^{2/9+o(1)})$. This is the first exponential improvement since the establishment of the $O(N^{1/4+o(1)})$ bound in 1977."

---

## F. van der Horst / order-finding route / provable subexponential

### F1. Harvey & Hittmeir 2026 — hypothesis dropped entirely
- **Status:** FOUND (primary)
- **URL:** `https://arxiv.org/abs/2601.11131`
- **Abstract, verbatim:**
  > "Abstract: We revisit the problem of rigorously and deterministically finding elements of large order in the multiplicative group of integers modulo a natural number $N$. Solving this problem is an essential step in several recent deterministic algorithms for factoring $N$, including the currently fastest ones. In 2018, the second author gave an algorithm that for a given target order $D \geq N^{2/5}$, finds either an element of order exceeding $D$, or a nontrivial divisor of $N$, or proves that $N$ is prime. The running time was \[ O\left(\frac{D^{1/2}}{(\log \log D)^{1/2}} \log^2 N \right) \] bit operations, asymptotically the same as the cost of computing the order of a single element using Sutherland's optimisation of the classical babystep-giantstep method. Subsequent work by several authors weakened the hypothesis $D \geq N^{2/5}$ to $D \geq N^{1/6}$. In this paper, we show that the hypothesis may be dropped altogether."
- **Note:** **van der Horst's bound is fully superseded.** The N^{2/5} hypothesis (itself a weakening of van der Horst's condition) is now removed entirely.

### F2. Oznovich & Volk 2025 (SODA)
- **Status:** FOUND (primary)
- **URL:** `https://arxiv.org/abs/2506.07668`
- **Abstract, verbatim:**
  > "Abstract: We give a deterministic algorithm that, given a composite number $N$ and a target order $D \ge N^{1/6}$, runs in time $D^{1/2+o(1)}$ and finds either an element $a \in \mathbb{Z}_N^*$ of multiplicative order at least $D$, or a nontrivial factor of $N$. Our algorithm improves upon an algorithm of Hittmeir ( arXiv:1608.08766 ), who designed a similar algorithm under the stronger assumption $D \ge N^{2/5}$. Hittmeir's algorithm played a crucial role in the recent breakthrough deterministic integer factorization algorithms of Hittmeir and Harvey ( arXiv:2006.16729 , arXiv:2010.05450 , arXiv:2105.11105 ). When $N$ is assumed to have an $r$-power divisor with $r\ge 2$, our algorithm provides the same guarantees assuming $D \ge N^{1/6r}$."

### F3. Nir 2026
- **Status:** FOUND (primary)
- **URL:** `https://arxiv.org/abs/2605.09592`
- **Abstract, verbatim:**
  > "Abstract: In this paper, we present an improvement for the problem of deterministically finding an element of large multiplicative order modulo some integer $N$. This problem arises as a key subroutine in current deterministic factoring algorithms, such as those proposed by Harvey and Hittmeir [Mathematics of Computation, 2021]."
- **Verbatim (the D-scale that matters — exp(√(2 log N log log N)), i.e. far below any power of N):**
  > "Specifically, let $D<N$ be positive integers with \begin{equation}\label{eq:abs} D > \exp\left(\sqrt{2\log N \log \log N}\right). \end{equation} We give a deterministic algorithm that does one of the following: Returns an element $a \in \mathbb{Z}_N^*$ with $\operatorname{ord}_N(a) > D$; Returns a non-trivial factor of $N$; Or reports that $N$ is prime. The running time of our algorithm is $O(D^{1/2 + o(1)})$."
- **Note:** D > exp(√(2 log N log log N)) with running time **O(D^{1/2+o(1)})**. This is the sub-power-in-N regime, but the running time is stated in D, and I did **not** fetch a paper deriving a factoring algorithm from it, so I make **no** claim that it yields a subexponential factoring bound.

### F4. van der Horst, "On the computation of multiplicative orders" (J. Théor. Nombres Bordeaux 1990)
- **Status:** **COULD NOT FETCH** — no arXiv record (pre-1991, arXiv does not cover it); zbMATH 403. Per F1/F2/F3 the bound is superseded twice over, but **I have not verified van der Horst's original statement** and make no quote from it.

### F5. Any proven subexponential factoring bound
- **Status:** **NOT FOUND, and the best available fetched statement says the opposite** — see G2 below, where the best rigorous factoring bound is quoted as L_n[1/2, 1]. No source claiming a proven subexponential (L_n[1/3, c]) general factoring bound was found. Quoted searches for `%22provable%20subexponential%22` and `%22provably%20subexponential%22` returned nothing.

---

## G. NFS: proven-correct implementations, and the unproven smoothness assumption

### G1. Lee & Venkatesan, "Rigorous Analysis of a Randomised Number Field Sieve" — THE central source for target G
- **Status:** FOUND (primary, full PDF)
- **URL:** `https://arxiv.org/pdf/1805.08873`
- **Abstract, verbatim:**
  > "Abstract: Factorisation of integers n is of number theoretic and cryptographic significance. The Number Field Sieve (NFS) introduced circa 1990, is still the state of the art algorithm, but no rigorous proof that it halts or generates relationships is known. We propose and analyse an explicitly randomised variant. For each n, we show that these randomised variants of the NFS and Coppersmith's multiple polynomial sieve find congruences of squares in expected times matching the best-known heuristic estimates."
- **§1, verbatim — NFS has been entirely heuristic, and it is not even known to halt:**
  > "The Number Field Sieve (NFS) has been the state of the art algorithm for factorisation since its introduction nearly three decades ago [6]. Unfortunately, has been thus far entirely heuristic [49], its analysis"
  > "It is a priori unclear how to argue that the NFS even halts [35]. Even assuming standard conjectures (e.g.; GRH), there is no analysis that any substantial part of the NFS will halt."
- **§1, verbatim — THE SMOOTHNESS ASSUMPTION IS EXACTLY THE UNPROVEN STEP, named:**
  > "In particular, the NFS and other algorithms critically depend on the existence of sufficient numbers of smooth elements among rational or algebraic integers on certain linear forms, which cannot be guaranteed in current algorithms."
- **§1, verbatim — the best rigorous analysis is exponential in the exponent:**
  > "The fastest algorithms with known rigorous analysis are unfortunately much slower, with the best result being Ln 12 , 1 + o(1) [33], where the basic operations are performed in the class group on quadratic forms"
- **§1, verbatim — the randomised variant's proven exponent:**
  > "We will show bounds on the expectation of the time taken to produce congruences of squares (x, y) : x2 ≡ y 2 mod (n). These bounds will be of form Ln 1 3 , Θ(1) , and are the first time that bounds of this type have been obtained for any factorisation algorithm."
- **Verbatim (the exact proven time, Theorem 2.1/2.3):**
  > "Theorems 2.1 (p. 5) and 2.3 (p. 5). There is a randomised variant of the Number Field Sieve which for each n finds congruences of squares x2 = y 2 mod (n) in expected time: Ln 1 3 , 1/3 64/9 + o(1) ≃ Ln 1 3 , 1.92299 . . . + o(1) ."
- **Verbatim (the non-triviality is still CONDITIONAL — Lee–Venkatesan's own Conjecture 7.1):**
  > "These congruences of squares are not trivially of the form x = ±y: conditional on a mild character assumption (Conjecture 7.1 (p. 39)), for n the product of two primes congruent to 3 mod 4, the factors of n may be recovered in the same asymptotic run time."
- **Verbatim (how they dodge the smooth-number second moment — "stochastic deepening"):**
  > "We use a probabilistic technique, which we term stochastic deepening, to avoid the need to show second moment bounds on the distribution of smooth numbers."
- **Verbatim (Remark 5.7, the core lemma of that dodge):**
  > "Conceptually, this lemma states that for non negative variables which do not vary too much, there must be a reasonably large set where the value is large, whose contribution to the mean is large. This is the core observation that permits stochastic deepening to provide a search algorithm whose run times are shown to be near optimal without establishing accurate variance bounds."
- **§3.1, verbatim — smooth-number DETECTION is rigorous; SMOOTH-NUMBER FINDING is not guaranteed:**
  > "As mentioned earlier, a key ingredient in combination of congruence algorithms is the detection and factorisation of y-smooth numbers. The main difficulty here is that the algorithm must be polynomial time in the logarithm of the integer it is to factor, although it is permitted to be merely sub-exponential in the logarithm of the smoothness bound. That such an algorithm exists is by no means guaranteed."
- **§3.1, Fact 3.18 + Corollary 3.19, verbatim (Lenstra–Pila–Pomerance hyperelliptic curve method — a PROVEN factoring bound):**
  > "Fact 3.18 (Lenstra, Pila and Pomerance [36, Theorem 1.1]). There exists a constant c such that the hyperelliptic curve method finds a non-trivial factor of any x which has a prime factor less than y in expected time bounded by Ly 23 , c (log x)"
  > "Corollary 3.19. Suppose y = logω(1) x. Then the hyperelliptic curve method can factor any y-smooth number below x in expected time at most Ly 32 , c (log x) = y o(1)"
- **Remark 3.20, verbatim — a case where short-interval smoothness IS unconditional (the Hasse–Weil interval):**
  > "Remark 3.20. Both the ECM and HECM are successful if the order of the Jacobian of the randomly chosen curve is smooth. In the HECM case, the Hasse-Weil interval is of the form [x − 4x3/4 , x + 4x3/4 ] , and the density of smooth numbers in such intervals is unconditionally understood."
- **Reference, verbatim:**
  > "[33] Hendrik W Lenstra and Carl Pomerance. A rigorous time bound for factoring integers. Journal of the American Mathematical Society, 5(3):483–516, 1992." / "[36] Hendrik W. Lenstra, Jr., Jonathan Pila, and Carl Pomerance. A hyperelliptic smoothness test, I. Philosophical Transactions of the Royal Society of London Series A, 345:397–408, 1993."
- **Note — the single most important sentence for the report is the "critically depend on the existence of sufficient numbers of smooth elements … which cannot be guaranteed" quote.** Lee–Venkatesan fix this by randomising **the search space (polynomial selection)**, not by proving smoothness exists at a specific point — so they get a proven *expected* L_n[1/3, 1.923] **search** time but only a **conditional** (Conj. 7.1) *factorisation*. They say so explicitly.

### G2. Barbulescu & Jouve 2023 — ECM complexity is PROVEN conditional on EH (target D∩G)
- **Status:** FOUND (primary, full PDF)
- **URL:** `https://arxiv.org/abs/2212.11724`, PDF `https://arxiv.org/pdf/2212.11724`
- **Abstract, verbatim (the sentence quoted in the brief, in full):**
  > "The complexity of the elliptic curve method of factorization (ECM) is proven under a strong conjectural form of existence of friable numbers in short intervals. In the present work we use friability to tackle a different version of ECM which is much more studied and implemented, especially because it enables the use of ECM-friendly curves. In the case of curves with complex multiplication (CM) we replace heuristic arguments by rigorous results conditional on the Elliott–Halberstam (EH) conjecture. The proven results mirror recent work concerning the count of primes p such that p − 1 is friable."
- **§1, verbatim — ECM's smoothness heuristic is stated as a heuristic, not a theorem:**
  > "In particular, the heuristics underlying the use of ECM as a friability test states that the larger ψE (x, y) gets, the more y-friable integers will be found by ECM inside a given set."
- **§1, verbatim — ECM termination is explicitly not guaranteed:**
  > "(note that there is no guarantee that the procedure terminates after testing finitely many curves)."
- **Remark 1, verbatim — the curve-independence step is unproven:**
  > "To the best of our knowledge, no rigorous argument proves the required “independence” property for the input curves at the present time even though a heuristic complexity to solve Problem 2 is well known ([CS06])."
- **§1, verbatim — what is actually proven:**
  > "Our main result (Theorem 1.2) roughly states that the probability that the number of Fp points on a given elliptic curve is friable approaches asymptotically the probability for any integer to be friable. In the case of CM1 elliptic curves our result is conditional on the Elliott–Halberstam conjecture (EH)"
- **Note:** **this paper is the cleanest statement that ECM's provability reduces exactly to a conjectural short-interval friability statement, replaced by EH.** Note the abstraction: ECM needs smoothness of |E(F_p)| over a *set of primes*, not smoothness of a value in an interval; EH replaces the short-interval friability input.

### G3. Couveignes–Lercier, "The number field sieve for composite integers"
- **Status:** **COULD NOT FETCH** — arXiv search `au:"Couveignes" AND abs:"number field sieve"` returned no results; zbMATH 403; **hal.science returned a 12525-byte JavaScript shell, not the document**, at both `https://hal.science/hal-01170942/document` and the HAL search URL. No statement quoted, no claim made.
- **Adjacent, verifiable substitute:** Lee–Venkatesan (G1) is the paper that directly answers G's question ("has NFS ever been *proved* to yield a subexponential algorithm?") with an explicit negative and a randomised partial fix.

### G4. Explicit statements that NFS's smoothness assumption is unproven
- **Status:** FOUND — G1 and G2 above are exactly this. The two canonical verbatim sentences are quoted there:
  - Lee–Venkatesan: "the NFS and other algorithms critically depend on the existence of sufficient numbers of smooth elements among rational or algebraic integers on certain linear forms, which cannot be guaranteed in current algorithms."
  - Lee–Venkatesan abstract: "no rigorous proof that it halts or generates relationships is known."

---

## Coverage ledger

| Target | Status | Primary URL |
|---|---|---|
| A Balog 1987 | FOUND (Numdam scan, OCR degraded) + clean secondary via Soundararajan | `https://www.numdam.org/item/AST_1987__147-148__27_0.pdf` ; `https://arxiv.org/pdf/1009.1591` |
| A Balog–Wooley | **COULD NOT FETCH** | — |
| A Friedlander–Iwaniec smooth/short intervals | **COULD NOT FETCH** | — |
| B Hildebrand 1986 | FOUND (exact range via Younis) | `https://arxiv.org/pdf/2409.05761` |
| B Hildebrand AP / Fouvry–Tenenbaum | citation only, **primary not fetched** | — |
| C Hildebrand–Tenenbaum 1986 | FOUND (exact range via Younis) | `https://arxiv.org/pdf/2409.05761` |
| C Best current all-intervals | FOUND (Jain 2025) | `https://arxiv.org/pdf/2502.10530` |
| D Smooth values of polynomials | FOUND (Bober et al.) | `https://arxiv.org/pdf/1710.01970` |
| D Fouvry–Lacroix | **COULD NOT FETCH** | — |
| D van de Woestijne | **COULD NOT FETCH** | — |
| D Two-variable a²−b³ | **NO SOURCE FOUND** | — |
| E Best provable factoring | FOUND (Harvey–Hittmeir N^{1/5}) | `https://arxiv.org/abs/2105.11105` |
| F van der Horst | **COULD NOT FETCH** (original), superseded twice over | — |
| F Order-finding sub-power | FOUND (Harvey–Hittmeir, Oznovich–Volk, Nir) | `https://arxiv.org/abs/2601.11131` etc. |
| F Provable subexponential factoring | **NOT FOUND**; contradicted by G1 | `https://arxiv.org/pdf/1805.08873` |
| G NFS rigor | FOUND (Lee–Venkatesan) | `https://arxiv.org/pdf/1805.08873` |
| G Couveignes–Lercier | **COULD NOT FETCH** (HAL blocked) | — |
| G ECM provability | FOUND (Barbulescu–Jouve) | `https://arxiv.org/pdf/2212.11724` |

### Failed routes (do not retry without new access)
- `export.arxiv.org/api/query` → 429 always
- `zbmath.org` → 403 Cloudflare (both WebFetch and curl)
- `api.semanticscholar.org/graph/v1` → 429
- `hal.science` → JS shell only
- arXiv search UI unquoted multi-word → OR-matches, returns noise (quote phrases)