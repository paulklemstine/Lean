# The Fading Echo of a Linear Machine

## A story told one map at a time

Imagine a long assembly line. At each station a worker performs a single,
fixed operation on whatever arrives, then passes the result down the line.
The operations need not be the same from station to station — one worker
might rotate the part, the next might flatten it, the next might project a
shadow of it onto a wall. What happens to the *richness* of the information
as the part travels down this line?

That, stripped of its industrial costume, is the question at the heart of
this work. The "part" is a vector in a vector space $V$. Each "worker" is a
**linear map** — an operation that respects addition and scaling. And the
whole assembly line is an infinite *stream* of such maps,

$$f : \mathbb{N} \to (V \to V),$$

one linear map $f(0), f(1), f(2), \dots$ for each station $0, 1, 2, \dots$.

The surprising and satisfying punchline, which we will build up to, is that
the information content flowing through such a line can only ever *fade or
hold steady* — never spontaneously sharpen — and that in finite dimensions
this fading must eventually stop, freezing into a permanent steady value.
The stream develops a fingerprint.

## Composing the journey

Before we can talk about fading, we need precise language for "what happens
between station $i$ and station $j$."

Start at station $i$ and walk $n$ steps forward. The cumulative effect is the
composition of the maps you pass through, applied in order. We call this the
**partial composite** and write it $\mathrm{compFrom}\,f\,i\,n$. It is defined
by the most natural recursion imaginable:

- Walking *zero* steps does nothing, so $\mathrm{compFrom}\,f\,i\,0$ is the
  **identity map** $\mathrm{id}$ — the map that returns its input untouched.
- Walking one more step means first doing everything up to now, then applying
  the next worker:
$$\mathrm{compFrom}\,f\,i\,(n+1) \;=\; f(i+n) \,\circ\, \mathrm{compFrom}\,f\,i\,n.$$

Here $\circ$ means "do the right-hand map first, then the left." So unrolling
the recursion gives exactly what you would expect:
$$\mathrm{compFrom}\,f\,i\,n \;=\; f(i+n-1)\circ\cdots\circ f(i+1)\circ f(i).$$

From this we name the real object of interest. The **transition
endomorphism** from index $i$ to index $j$ is simply the partial composite
that carries you the whole way:
$$\mathrm{transEndo}\,f\,i\,j \;=\; \mathrm{compFrom}\,f\,i\,(j-i).$$

(The word *endomorphism* just means "a map from a space back to itself" — the
parts never leave $V$.) When $j \ge i$, this is the net operation performed by
the segment of the assembly line between station $i$ and station $j$.

## The assembly line splits cleanly

The first thing any good bookkeeping system should do is *compose without
contradiction*. If you travel from station $i$ to station $j$, and then from
$j$ to $k$, the total effect had better equal traveling straight from $i$ to
$k$. It does, and this is our first theorem.

> **Composition law (`transEndo_comp`).** If $i \le j \le k$, then
> $$\mathrm{transEndo}\,f\,i\,k \;=\; \mathrm{transEndo}\,f\,j\,k \,\circ\, \mathrm{transEndo}\,f\,i\,j.$$

In words: the journey from $i$ to $k$ factors *exactly* as "first go $i \to j$,
then go $j \to k$." This is the linear-algebra version of the obvious truth
that an itinerary can be broken at any intermediate stop. Underneath it sits a
purely combinatorial identity about the partial composites,

> **Additivity (`compFrom_add`).**
> $$\mathrm{compFrom}\,f\,i\,(m+n) \;=\; \mathrm{compFrom}\,f\,(i+m)\,n \,\circ\, \mathrm{compFrom}\,f\,i\,m,$$

which says "walk $m+n$ steps" $=$ "walk $m$ steps, then walk $n$ more from where
you landed." Proven by induction on $n$, it is the engine that drives
everything else.

## Why information can only fade

Now for the heart of the matter. We need a way to measure how much
information a linear map preserves. The right notion is **rank**: the
dimension of the map's image — the size of the "shadow" it casts. A map of
high rank spreads its inputs across many independent directions; a map of low
rank collapses them. Rank zero means everything is crushed to a single point.

Here is the key intuition. Composition can *destroy* information but never
*create* it. If you take the output of one map and feed it into another, the
second map can only work with what it received. It can fold, collapse, or
faithfully relay that information — but it cannot conjure new independent
directions out of nothing. Formally, for any linear maps $g$ and $h$,
$$\mathrm{rank}(g \circ h) \;\le\; \mathrm{rank}(h).$$
The composite is at most as rich as the *first* map applied.

Combine this with the composition law and a beautiful monotonicity falls out
for free. Lengthening the assembly-line segment can only shrink its rank.

> **Rank is antitone (`rank_transEndo_antitone`).** If $i \le j \le k$, then
> $$\mathrm{rank}\big(\mathrm{transEndo}\,f\,i\,k\big) \;\le\; \mathrm{rank}\big(\mathrm{transEndo}\,f\,i\,j\big).$$

The proof is a single line of reasoning: the longer journey $i \to k$ is the
shorter journey $i \to j$ followed by more processing, and tacking processing
onto the *end* cannot raise the rank. The same statement holds at the level of
partial composites:

> **(`rank_compFrom_antitone`).** If $n \le m$, then
> $\mathrm{rank}\big(\mathrm{compFrom}\,f\,i\,m\big) \le \mathrm{rank}\big(\mathrm{compFrom}\,f\,i\,n\big).$

This is the "fading echo": as the part travels further down the line, the
information it carries about its original self can only diminish or stay
level. An echo never gets louder.

## The echo must eventually settle

A fading quantity could, in principle, fade *forever* — think of $1, \tfrac12,
\tfrac14, \tfrac18, \dots$, which decreases at every step yet never repeats a
value. Could the rank of our transitions behave like that, dropping a little
at every station, never stabilizing?

In a **finite-dimensional** space, no. And the reason is wonderfully simple.
Rank is a *whole number*, and it is bounded below by $0$ and above by the
dimension $d = \dim V$ of the whole space. A sequence of whole numbers between
$0$ and $d$ that never increases simply cannot decrease forever — it has only
finitely many values it could possibly take, and once it stops dropping, it
must stay put.

To state this crisply we record the rank as an ordinary natural number,
$$\mathrm{rankSeq}\,f\,i\,j \;=\; \big\lfloor \mathrm{rank}(\mathrm{transEndo}\,f\,i\,j)\big\rfloor,$$
and prove three facts that together pin down its behaviour:

> **Bounded (`rankSeq_le_finrank`).** $\mathrm{rankSeq}\,f\,i\,j \le \dim V$ always.
>
> **Antitone (`rankSeq_zero_antitone`).** The sequence $m \mapsto \mathrm{rankSeq}\,f\,0\,m$ never increases.
>
> **Eventually constant (`rankSeq_eventually_const`).** There is some station
> $N$ beyond which the value never changes again:
> $$\exists\,N,\ \forall\,m \ge N,\quad \mathrm{rankSeq}\,f\,0\,m = \mathrm{rankSeq}\,f\,0\,N.$$

The last result rests on a clean, reusable order-theoretic gem worth stating
on its own:

> **Stabilization of monotone integer chains (`antitone_nat_eventually_const`).**
> *Every* non-increasing sequence of natural numbers is eventually constant.

Its proof is a small jewel: among all the values the sequence ever takes,
there is a least one (the natural numbers are well-ordered). Once the sequence
reaches that least value it can never go lower — there is nothing lower — and
since it never goes up either, it is stuck there for good.

## The stream's fingerprint

Step back and look at what we have built. Out of an arbitrary infinite stream
of linear maps — a wholly generic, possibly chaotic object — we have
extracted a single, finite, non-increasing, eventually-constant sequence of
integers: its rank profile. This sequence is an **invariant**, a fingerprint.
It does not care about the intricate details of which map does what; it
records only how information attenuates as it flows down the line, and the
permanent floor it settles into.

This floor has meaning. In the special case where every worker performs the
*same* operation $g$ — a constant stream — the transition from $0$ to $m$ is
just $g$ applied $m$ times, $g^m$. The composition law specializes to the
familiar exponent rule $g^{m+n} = g^m \circ g^n$, and the eventual rank is the
dimension of the so-called *generalized image* of $g$: the part of the space
that $g$ never manages to destroy, no matter how many times it acts. This is
the classical **Fitting core** of an operator, recovered here as a special
case of a far more general phenomenon about arbitrary streams.

## A Pythagorean coda

There is a pleasing kinship between this story and the oldest theorem in
mathematics. The Pythagorean relation $a^2 + b^2 = c^2$ is, at bottom, a
statement about how lengths combine when you move along two perpendicular
legs of a journey. Our composition law is its structural cousin: a statement
about how *transformations* combine when you move along the legs of an
abstract journey through index space. And just as the Pythagorean theorem
gives a single number — the hypotenuse — summarizing a two-step trip, our
rank profile gives a single eventual number summarizing an infinite one.

The deeper lesson is one mathematicians return to again and again: when faced
with something infinite and unruly, look for the quantity that can only move
one way. Monotonicity plus boundedness is a trap from which no sequence
escapes — it must come to rest. The fading echo of a linear machine,
however complicated the machine, always finds its final, silent pitch.
