# The "under-attacked axis" finding was a database artifact — IACR is reachable

**Round 49, orchestrator. Correcting `notes/FF_litsweep2.md`.**

## What the sweep reported

The literature sweep reported that the auxiliary-information axis is *so under-attacked that
arXiv cannot reach it*:

> `all:"auxiliary information" AND all:factoring` returns 61 hits; **"I read all 61 titles
> and every one is a matrix-factorization recommender systems."**

It also reported `all:"partial key exposure"` returning **exactly one unrelated hit**, and
based a major conclusion on it:

> **"The axis is under-attacked, not under-broken."**

It disclosed the caveat honestly:

> *"I had no working route to eprint.iacr.org, so §3's emptiness claims are about arXiv+OpenAlex,
> **not** about TCHES/INDOCRYPT where side-channel partial-information results genuinely live."*

**The caveat was correct and the conclusion drawn from it was not.** The route was available.

## eprint.iacr.org IS reachable from this host

```
$ curl -o /dev/null -w "%{http_code}" https://eprint.iacr.org/search?q=partial+key+exposure
200
```

The `/api/search` endpoint 404s, but **the HTML search works** — which is why the agent,
probing the API, concluded the site was unreachable.

Re-running the sweep's own queries:

| query | arXiv (per sweep) | **eprint** |
|---|---|---|
| `partial key exposure` | 1 (unrelated) | **36** |
| `factoring with hints` | 1 (via literal phrase) | **24** |
| `auxiliary information factoring` | 61 (all recommender systems) | **7** |
| `Jacobi symbol graph` | 0 | **0** |

## What changes

**The auxiliary-information axis is NOT empty.** 7 + 24 + 36 results on the database where this
literature actually lives. The sweep's headline conclusion — *"the axis is under-attacked, not
under-broken"* — **is not established**, and must not be carried into the census as a claim.

Note what the sweep *got* right: it recorded that its emptiness claims were database-scoped, it
flagged `abs:"Williams" AND abs:"p+1" AND abs:factoring` → 0 as "obviously false as a fact about
the world," and it **weighted its conclusions accordingly**. That is good practice and the
caveat is what made this check possible.

**The Jacobi-symbol-graph axis IS empty** — confirmed on a second, independent database. That
finding stands, and it is the more consequential one: it is the only axis where the census's
closure rests on an *unproven* assertion ("φ is polylog-equivalent to factoring," which the
census itself flags as "asserted with no proof or citation").

## The failure mode — this is the fifth instance

> **Measuring the wrong population.**

It is exactly the shape of the round's E-6c error: supply numbers computed inside a *box*
rather than over the algorithm's population. Here the population is "papers about crypto," and
the instrument was a physics/CS preprint server. arXiv indexes almost no side-channel
cryptography, because that literature is published in **TCHES and INDOCRYPT proceedings** and
preprinted on IACR.

The generalization, which now covers most of this round's errors:

> **Before concluding that a population is empty, check that your instrument can see it.**
> A null result from an instrument that has never produced a non-null on known-present material
> is evidence about the instrument.

**A direct test:** the sweep ran `all:"partial key exposure"` → 1 hit on arXiv. On eprint, 36.
The arXiv number was *not wrong* — it was correctly measured on the wrong database, and then
reported as a fact about the world.

## Operational note

`https://eprint.iacr.org/search?q=<urlencoded query>` works and returns an HTML page containing
a literal `N results` string. Add it to the standing route list:

- arXiv API — `https://export.arxiv.org/api/query` (`http://` gives a 301 empty body)
- **IACR eprint — `https://eprint.iacr.org/search?q=` (the `/api/` path 404s; use HTML)**
- Crossref — `https://api.crossref.org/works?filter=isbn:<ISBN>` for a full LNCS TOC in one call
- Crossref — `https://api.crossref.org/works?query.bibliographic=` for existence checks
- zbMATH author publication lists, for disproof by author

⚠️ As always: **WebSearch fabricates citations on this host.** Sixteen recorded instances, and
one agent invented a Couveignes–Lercier paper while briefing another agent on citation
discipline.