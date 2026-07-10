# Graph Coloring with Emotions: Counting the Moods a Friendship Network Can Hold

Imagine a party. Everyone in the room has a mood — happy, sad, angry, afraid,
disgusted, surprised — and there is one social rule: no two close friends are
allowed to be in the *same* mood at the same time. Two friends both fuming?
Awkward. Two friends both radiating joy? Redundant. The room feels most alive,
this rule insists, when adjacent people carry contrasting feelings.

How many moods does the room *need* so that this rule can be satisfied at all?
And once the room is large and tangled with friendships, how many *different
ways* are there to hand out moods legally? These two innocent questions turn out
to be old friends of mathematicians in disguise. They are questions about
**graph coloring**, and they connect a whimsical thought experiment about human
emotion to one of the most elegant objects in combinatorics: the **chromatic
polynomial**.

## From a party to a graph

Strip away the personalities and you are left with a **graph**: a collection of
dots (people) and lines (friendships). A "mood assignment" that obeys the
no-two-friends-alike rule is exactly what mathematicians call a **proper
coloring** — a way of painting each dot with one of $k$ colors so that no line
connects two dots of the same color. The moods are just colors with feelings.

The magic begins when you *count* the legal colorings. For a graph $G$ and a
palette of $k$ colors, let $\chi_G(k)$ denote the number of proper $k$-colorings.
A century ago George Birkhoff discovered something remarkable: this count is
always a **polynomial** in $k$. Feed in the number of available moods, and a
single fixed polynomial spits out the number of legal mood assignments. It is
called the chromatic polynomial, and it encodes, in its coefficients and its
roots, a surprising amount about the shape of the network.

For example, take a **triangle** — three people who are all mutual friends,
$K_3$. With $k$ moods, the first person has $k$ choices, the second must differ
($k-1$ choices), and the third must differ from both ($k-2$ choices). So
$$\chi_{K_3}(k) = k(k-1)(k-2).$$
Plug in $k = 2$ and you get $2 \cdot 1 \cdot 0 = 0$: with only two moods, a
triangle of friends is *impossible* to satisfy. Plug in $k = 6$ and you get
$6 \cdot 5 \cdot 4 = 120$ perfectly valid emotional configurations.

## The six basic emotions

Psychologists since Paul Ekman have argued that human faces broadcast six
"basic" emotions the whole world recognizes: **happiness, sadness, anger, fear,
disgust, surprise**. Six moods. So it is irresistible to ask: given a real
social network, how many ways can you assign these six emotions to people so
that no two friends feel the same? The answer is simply $\chi_G(6)$ — evaluate
the network's chromatic polynomial at six.

But there is a subtler and more interesting question hiding underneath. Not
*how many* colorings, but *how few colors are enough*? This is the network's
**chromatic number** $\chi(G)$: the smallest palette size for which at least one
legal coloring exists. A triangle needs three; a single friendship needs two; a
lonely person with no friends needs only one.

Here the emotion story adds a human twist. A palette of one emotion is no
palette at all — it means everyone feels the same thing, which is not an
emotional *life*, it is a mood. Even two emotions is a thin caricature: the
world split into the happy and the sad. Genuine emotional texture, we argue,
requires **at least three** categories. So we define the **emotional chromatic
number** of a network:

> $\chi_E(G)$ is the smallest number $k$ of emotions, **with $k \ge 3$**, such
> that the network admits a legal assignment of $k$ emotions in which no two
> friends share a feeling.

In symbols, $\chi_E(G)$ is the least $k \ge 3$ with $\chi_G(k) > 0$. It is the
ordinary chromatic number with a floor bolted on at three: enough colors to be
legal, but never fewer than three, because emotional life is not binary.

## What the emotional chromatic number knows

This single number turns out to have a clean and satisfying theory. Three
results anchor it.

**Cliques: everyone different.** A *clique* is a group of $n$ people who are all
mutual friends — the complete graph $K_n$. Since every pair is joined, every
person must feel something different, so at least $n$ emotions are required, and
$n$ clearly suffice. Applying the floor,
$$\chi_E(K_n) = \max(n, 3).$$
A pair of best friends ($K_2$) needs, emotionally speaking, *three* categories
to breathe, even though two colors would technically separate them. A triangle,
a foursome, a five-person clique: each needs exactly as many emotions as it has
members.

**Cycles: the ring always needs three.** A *cycle* $C_n$ is a ring of friends —
person 1 befriends person 2 befriends person 3, all the way around back to
person 1. Classical coloring theory says a cycle needs two colors when its
length $n$ is **even** (just alternate) and three colors when $n$ is **odd**
(the alternation collides when it wraps around). But emotionally, the floor
erases this distinction:
$$\chi_E(C_n) = 3 \quad \text{for every } n \ge 3.$$
Every friendship ring, long or short, even or odd, needs exactly three
emotions — no more, no less. The even rings *could* get by with two colors
mathematically, but not emotionally.

**The six-emotion window.** Real friendship networks are not cliques of a
thousand people; they are sparse, locally clustered webs. If a network can be
legally colored with six emotions at all — that is, if $\chi(G) \le 6$ — then
its emotional chromatic number lands squarely in the window
$$3 \le \chi_E(G) \le 6.$$
The lower bound is the emotional floor; the upper bound is the six basic
emotions. This is why Ekman's palette feels "big enough" for ordinary social
life: the vast majority of human networks are colorable well within six colors,
so six emotions comfortably cover them, while three is always the irreducible
minimum.

## The myth of the two-emotion split

There is a piece of folklore worth puncturing. A network is **bipartite** when
its people split cleanly into two camps with all friendships running *between*
the camps and none inside — think of a dating app graph, or students versus
teachers. Bipartite graphs are exactly the graphs colorable with two colors, and
so the chromatic polynomial of any bipartite graph with at least one edge
vanishes at... well, the folklore says "$k = 2$," implying two emotions never
work for a split community.

The truth is the reverse. Bipartite graphs are precisely the ones for which two
emotions *do* work: $\chi_G(2) = 2 > 0$ for a connected bipartite graph, because
you can paint one camp happy and the other sad. The genuine root sits at
$k = 1$: a single emotion fails the moment there is even one friendship, since
that friendship demands a contrast. So the honest statement is that *every*
network with at least one edge has $\chi_G(1) = 0$, and bipartite networks are
the ones that *first succeed* at $k = 2$. Emotionally, though, we never let them
stop there — the floor pushes them up to three, which is why a cleanly split
community still, in the emotional sense, needs $\chi_E = 3$.

## Why a polynomial for a party?

It is worth pausing on how strange and lovely Birkhoff's discovery is. There is
no obvious reason that the number of legal mood assignments should be a *smooth
polynomial* in the number of moods. Counting problems are usually jagged. Yet
the count $\chi_G(k)$ is governed by a single algebraic law, provable by a
beautiful recursive principle called **deletion–contraction**: to count the
colorings of a network, pick any friendship, count the colorings that ignore it,
and subtract the colorings that would illegally merge its two endpoints. This
recursion peels the graph apart edge by edge and reassembles the polynomial from
the pieces. It is the engine behind every computation above, and it is why the
whole subject hangs together.

The polynomial's roots — the values of $k$ where the count drops to zero — mark
the palette sizes that are *impossible*. The largest integer root, plus one, is
essentially the chromatic number. So the roots of an abstract polynomial are
telling you something concrete and human: how much emotional diversity a
community structurally demands.

## Emotional diversity as a measurement

Step back and the picture is this. Every social network carries a hidden number,
$\chi_E(G)$, that measures the *minimum emotional diversity* the network can
tolerate without two friends echoing each other. Tightly knit cliques demand a
lot — one distinct feeling per member. Sprawling sparse webs of ordinary
friendships demand little — usually three, occasionally four or five, and almost
never more than six. The chromatic polynomial refines this from a single number
into a full spectrum: not just *how few* emotions are needed, but *how many
ways* a given emotional palette can be legally deployed.

The claim is not, of course, that people literally obey a no-matching-moods
rule. It is that the mathematics built to answer a playful question — *how many
moods does a friendship network need?* — is exactly the mathematics of graph
coloring, one of the deepest and most useful theories in discrete mathematics,
with applications from scheduling exams to allocating radio frequencies to
compiling computer programs. The emotions are a costume. Underneath, the
chromatic polynomial is quietly measuring the combinatorial texture of human
connection, and telling us that three is the floor, six is a generous ceiling,
and the shape of your friendships decides where in between you land.
