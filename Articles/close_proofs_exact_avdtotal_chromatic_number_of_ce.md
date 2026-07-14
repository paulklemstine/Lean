# The Colours at the Centre of a Graph

## A puzzle about painting networks

Imagine you are handed a network — dots joined by lines. Maybe the dots are
radio transmitters and the lines mark pairs that interfere; maybe they are
courses at a university and the lines mark pairs that share a student. A very
old and very practical question asks: how few *colours* do you need to paint
the parts of this network so that things which clash never share a colour?

The most famous version colours only the dots. But there is a richer, more
demanding game in which you must colour **everything at once**: every dot *and*
every line. A colouring is *proper* — the honest kind — when any two parts that
touch get different colours. Two lines that meet at a dot must differ; a dot and
each line leaving it must differ; and two dots joined by a line must differ.
This is called a **total colouring**, and it is the natural language for
problems where both the "nodes" and the "connections" carry information that
must be kept apart.

Total colouring already forces your hand. Look at any single dot of degree $d$
(that is, with $d$ lines leaving it). The dot itself, together with its $d$
lines, forms a little bouquet in which everything touches everything else. All
$d+1$ of these objects must get *different* colours. So no matter how clever you
are, you can never finish with fewer than $\Delta + 1$ colours, where $\Delta$
is the largest degree in the whole network.

## Making neighbours tell themselves apart

Now add one more twist, and the puzzle becomes genuinely subtle. Give every dot
a *palette signature*: the set of colours you see when you look at the dot and
all the lines touching it. Two dots that are joined by a line are neighbours,
and we demand that **neighbours have different signatures**. It is not enough
for the paint to be proper; adjacent dots must be *distinguishable* by the
company their colours keep.

This refinement is called an **adjacent-vertex-distinguishing total colouring**
— an *AVD-total colouring* for short. The smallest number of colours that lets
you do it is written $\chi''_a$, the *AVD-total chromatic number* of the
network. It is one of the most delicate colouring parameters in the subject,
because it couples a local constraint (proper colouring) with a global one
(every adjacent pair must end up with different signatures).

The distinguishing rule sharpens the earlier bound in a beautiful way. Suppose
two neighbouring dots both have the *maximum* degree $\Delta$. Each of them,
proper colouring alone, is forced to display all $\Delta + 1$ colours in its
signature — its bouquet already uses that many. If your entire palette has only
$\Delta + 1$ colours, then *both* signatures are the whole palette, and they are
identical. The neighbours become indistinguishable. So the moment two
maximum-degree dots sit next to each other, you are pushed up to at least
$\Delta + 2$ colours. This tiny observation is the engine behind everything that
follows.

## The central graph: a network turned inside out

The networks we study here are not raw; they are built by a specific
construction called the **central graph**. Starting from any graph $G$, its
central graph $C(G)$ is made in two moves:

1. **Subdivide every line.** Drop a brand-new dot in the middle of each original
   line, splitting it into two shorter lines. These new dots are the
   *subdivision vertices*, and each of them has degree exactly $2$.

2. **Connect every pair of strangers.** Whenever two of the *original* dots were
   *not* joined in $G$, join them now.

The result is a striking inversion. In the original graph, being adjacent was a
special relationship. In the central graph, the original dots are joined
precisely to those they used to *avoid*. An original dot $v$ ends up connected
to the subdivision vertices sitting on its own former lines, plus to every dot
it was previously not adjacent to. Count these: if $G$ had $|V|$ dots in total,
$v$ is now joined to everything except itself — its degree in $C(G)$ is exactly
$|V| - 1$. Every original dot becomes a maximum-degree dot, all sharing the same
degree $|V| - 1$.

That single fact is dynamite. Recall the engine: two adjacent maximum-degree
dots force $\Delta + 2$ colours. And in a central graph, as soon as the original
graph had any two strangers at all, those two strangers are now *adjacent*
maximum-degree dots. So the central graph is almost engineered to be hard to
AVD-total-colour.

## Regular graphs and the conjecture

We focus on the most symmetric inputs: **regular graphs**. A graph is
$d$-regular when every dot has exactly $d$ lines — perfect local uniformity.
Cycles, grids on a torus, the edges of a cube, the "cocktail-party" graphs: all
regular. Regularity is the natural setting in which to hope for a clean formula,
because there is no lopsidedness to spoil the accounting.

The guiding conjecture in this corner of the subject predicts a remarkably tidy
answer. For every $d$-regular graph $G$ with $d \ge 2$ that is **not** complete
(a complete graph is one where everyone is already joined to everyone, leaving
no strangers), it proposes
$$\chi''_a\big(C(G)\big) = d + 3.$$
Three more colours than the regularity degree — always, regardless of the size
or shape of $G$. It is the kind of statement that is either a small miracle or
too good to be true, and pinning down exactly *which* is the story of this work.

## What we prove: the lower half, exactly

Our main results establish the **lower half** of the conjecture rigorously, and
along the way reveal precisely where the conjecture must be handled with care.

**A counting fact to begin.** If a $d$-regular graph is not complete, it has at
least $d+2$ dots. The reason is a clean pigeonhole: pick two strangers $a$ and
$b$. Then $a$, the vertex $b$, and the $d$ neighbours of $a$ are all distinct —
$b$ is not among $a$'s neighbours precisely because they are strangers. That is
$d + 2$ different dots, so $|V| \ge d + 2$. We record this as the identity
$$|V(G)| \ge d + 2.$$

**The obstruction.** For such a graph, the central graph $C(G)$ admits **no**
AVD-total colouring with only $d + 2$ colours. Here the pieces click together.
Any proper total colouring must give distinct colours to the bouquet at an
original dot $a$, which has $|V|$ elements; squeezing $|V|$ distinct colours into
a palette of size $d+2$ forces $|V| \le d+2$. Combined with the counting fact,
this pins $|V| = d + 2$ exactly. But then the two strangers $a$ and $b$ are
adjacent maximum-degree dots in a palette of size exactly $\Delta + 1$, and the
engine fires: their signatures are both the full palette, so they cannot be
distinguished. No such colouring exists.

**Padding never helps.** One might hope to sneak under the bound with *fewer*
colours. It cannot happen, because AVD-total colourings are robust to enlarging
the palette: any AVD-total colouring with $n$ colours can be reused verbatim
with $m \ge n$ colours (you simply leave the extra colours unused, and every
signature and every distinction is preserved). So the set of workable palette
sizes has no holes — it is an interval reaching up to infinity. If $d+2$ colours
fail, then so does every smaller number.

**The lower bound.** Putting these together, *every* AVD-total colouring of
$C(G)$ uses at least $d + 3$ colours:
$$\chi''_a\big(C(G)\big) \ge d + 3.$$
This is exactly the lower half of the conjectured equality — proven for all
non-complete regular graphs of degree at least two.

**A concrete case.** The five-cycle $C_5$ — five dots in a ring — is
$2$-regular and not complete. Our bound with $d = 2$ says its central graph
needs at least $5$ colours for any AVD-total colouring.

## The twist in the tale

Here the story takes an honest and instructive turn. There is a *sharper* lower
bound hiding in the same construction. Because every original dot of $C(G)$ has
degree $|V| - 1$, and adjacent original dots always exist, the engine actually
delivers
$$\chi''_a\big(C(G)\big) \ge |V| + 1.$$

Now compare the two bounds. The counting fact guarantees $|V| \ge d + 2$, so
$|V| + 1 \ge d + 3$. The $|V|$-governed bound is *at least as strong*, and often
strictly stronger. The five-cycle makes this vivid: there $|V| = 5$ while
$d + 2 = 4$, so the sharp bound demands at least $6$ colours, comfortably beyond
the $d + 3 = 5$ predicted by the naïve conjecture.

The conclusion is subtle and worth stating plainly: the clean equality
$\chi''_a(C(G)) = d + 3$ **cannot hold in general**. It can only hold in the
razor-thin extremal regime where $|V| = d + 2$ — that is, when each dot has
exactly *one* stranger. In graph language, this happens precisely when the
"complement" of $G$ (the graph of strangers) is a perfect matching: everyone
paired off with exactly one other. These are the elegant **cocktail-party
graphs**, the complete graphs $K_{d+2}$ with one perfect matching removed. Only
there does the tidy formula have a chance.

## Why it matters

This is a small parable about the life of a conjecture. A formula that looks
universal — "always $d + 3$" — turns out to be true only in a special extremal
family, and to *fail* on something as innocent as a pentagon. The value of a
rigorous treatment is exactly this: it does not merely confirm a hoped-for
answer, it locates the boundary between where the answer holds and where it
breaks, and it hands us the sharper statement that survives.

Colouring problems of this flavour are not idle. Total colourings model
situations where both objects and their interactions must be scheduled or
labelled without conflict — assigning frequencies to both stations and the links
between them, or time-slots to both tasks and the handovers connecting them. The
distinguishing condition adds a layer of *local identifiability*: neighbours
must be told apart by the palette they present, a natural requirement whenever a
node needs to recognise that it is not looking at a mirror of itself. Central
graphs, in turn, are a clean testbed where these constraints reach their extreme,
every original node forced to maximum degree at once.

What remains is the other half of the story: the matching **upper bound** in the
extremal regime — building an explicit colouring with $d + 3$ colours for
cocktail-party graphs and proving the equality there — together with the exact
values for cycles and a general upper bound closing the gap. The lower half is
now settled, sharpened, and, pleasingly, its limits are understood exactly.
