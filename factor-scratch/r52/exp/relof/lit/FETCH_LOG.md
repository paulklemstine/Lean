# QQ literature fetch log (2026-10-04)

WebSearch NOT used (it fabricates on this host). Routes actually used:
  https://arxiv.org/pdf/2007.02730 , /2006.06197 , /1408.0718   -- HTTP 200
  https://export.arxiv.org/api/query (metadata + full-text search)
  https://eprint.iacr.org/search?q=...   (HTML; /api/ path 404s)
  https://zbmath.org/?q=... , https://api.crossref.org/works?filter=isbn:...
  OpenAlex, Semantic Scholar, dblp, DDG

All formulas below were read off RENDERED PAGE IMAGES (pdftoppm 200 dpi),
not pdftotext.

## VERDICTS

### Q1  c = (64/9)^(1/3) = 1.92299942707654450976...   CONFIRMED
arXiv:2007.02730v2 (Le Gluher-Spaenlehauer-Thome, Math. Cryptol. 1(1):1-18, 2021),
p.1, Formula (1), rendered PNG:
  "The asymptotic complexity of the usual variant of NFS to factor an integer N ...
   is known to be exp(cbrt(64/9)(log N)^(1/3)(log log N)^(2/3)(1+xi(N)))"
Corroborated: arXiv:2006.06197 p.4 (Boudot et al., CADO-NFS RSA-240/DLP-240);
               arXiv:1408.0718v4 p.1 (Barbulescu et al.) -- same constant for
               prime-field DL.

### Q2  "turbocharged NFS, c = (32/9)^(1/3) = 1.5262857"   NOT FOUND -- ALMOST CERTAINLY WRONG
(32/9)^(1/3) = 1.52628565673777582374... ; ratio to 1.9230 is exactly 2^(1/3).
Zero results on EVERY route:
  arXiv API metadata  all:"turbocharg"        -> 100 hits, all non-crypto
  arXiv FULL-TEXT search, 14 query variants   -> NO RESULTS
  eprint.iacr.org/search?q=turbocharg        -> n=0
  zbmath.org/?q=turbocharg                   -> 0 documents
  Crossref query.title=turbocharging         -> automotive only
  OpenAlex fulltext "turbocharg"+"number field sieve" -> count 0
  Semantic Scholar -> 1880 hits, none turbocharged-NFS
What (32/9)^(1/3) ACTUALLY IS: the pre-2013 small-characteristic FUNCTION FIELD SIEVE
constant for DISCRETE LOGS. arXiv:1408.0718v4 p.1 rendered:
  "Before 2013, the best known complexity of L_Q(1/3, cbrt(32/9)) was obtained
   with the Function Field Sieve ..."
Wrong algorithm, wrong problem. That same PDF's abstract warns:
  "This unpublished version contains some inexact statements."

### Q3  is 1.9230 still state of the art for FACTORING?   YES
Only improvements found are DL-only. arXiv:1408.0718v4 pp.1-2:
  "using more number fields can improve the complexity ... in the large
   characteristic case we have c = cbrt((92+26*sqrt(13))/27) ... these multiple
   number field variants have not been used for practical record computations
   (they have not yet been used either for records in integer factoring)"
((92+26*sqrt(13))/27)^(1/3) = 1.9018836119.

### Q4  polynomial selection improves the asymptotic constant?   NOT FOUND
arXiv:1109.6398 (Coxon), arXiv:1412.6011 (Coxon), arXiv:1403.0184 (Barbulescu-Lachand)
all fetched HTTP 200, none states an asymptotic constant.
Coppersmith's 1/3-weight paper is not on arXiv; zbMATH ti: searches return 0.

### Q5  the growth-rate warning -- REAL, and there is a bigger error underneath
(a) arXiv:2007.02730 abstract:
      "numerical experiments indicate that this series starts converging only for
       N > exp(exp(25)), far beyond the practical range of NFS. This raises doubts
       on the relevance of NFS running time estimates that are based on setting xi = 0"
    Thm. 17 (p.2 rendered): xi(N) = (4 logloglog N)/(3 loglog N) + O(1/loglog N).
    Same page: "g(2^2048) ~ 2^16, while g_0(2^2048) ~ 2^61 ... Carelessly neglecting
    the o(1) term can lead to dramatic errors."
    arXiv:2006.06197 p.4: "(1+o(1)) ... reveals a significant lack of accuracy ...
    which easily swallows any speedup or slowdown that would be polynomial in log N."
(b) The standard factor-base formula is ln B = (8/9)^(1/3) (ln N)^(1/3)(ln ln N)^(2/3),
    NOT L^(2/3)(ln L)^(1/3)/(3c).  (8/9)^(1/3) = 0.9614997 = c/2 exactly.
    Real fetched data -- CADO-NFS RSA-240, arXiv:2006.06197 sec 4.3/4.4:
      "a sieving bound of 2^31 was perhaps not optimal but close to it"
    sieve area 2^32, 794 core-years -> actual ln B = 21.49 vs asymptotic 26.98,
    i.e. the L[1/3] model OVER-predicts B by ~2^8 at realistic sizes.
(c) RSA-768 / RSA-2048 actual sieving bounds: NOT FOUND (CADO challenge pages
    404/000, wayback empty; RSA-768 record paper DOI 10.1007/978-3-642-14623-7_18,
    ANTS 2010, confirmed via OpenAlex but paywalled).

### Q6  the standard NFS cost-model claims
(a) NFS relation values are m*Y^3, NOT N*Y^3.  arXiv:2007.02730 p.3 rendered:
      "|Res_x(u - vx, f_1(x))| <= M_1 = (d+1) m A^d",  m = ceil(N^(1/(d+1)))
    (quartic form).
(b) ln B formula -- see Q5(b).
(c) Relations needed: p.3 "at least (pi_{K_0}(B_0)+pi_{K_1}(B_1))"; p.4 Chebotarev.
    So B/ln B = pi(B) is the RATIONAL side only; the cost model uses Theta(B).

## HTTP status / access notes
  arXiv PDFs 2007.02730, 2006.06197, 1408.0718  : HTTP 200
  eprint 2020/829, 2020/697 PDFs               : HTTP 403 (all user agents)
  CADO challenge pages                          : 404 / 000
