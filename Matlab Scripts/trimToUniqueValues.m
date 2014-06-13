%This script will generate only unqiue values of CPU and 
% its corresponding TCT. It does so by rounding off the CPU
%values and picking the unique values from them.
%

pi_cpu = round(pi_cpu);
[~, idx] = unique(pi_cpu);
pi_cpu = pi_cpu(idx);
pi_tct = pi_tct(idx);

wc_cpu = round(wc_cpu);
[~, idx] = unique(wc_cpu);
wc_cpu = wc_cpu(idx);
wc_tct = wc_tct(idx);

terasort_cpu = round(terasort_cpu);
[~, idx] = unique(terasort_cpu);
terasort_cpu = terasort_cpu(idx);
terasort_tct = terasort_tct(idx);

grepsearch_cpu = round(grepsearch_cpu);
[~, idx] = unique(grepsearch_cpu);
grepsearch_cpu = grepsearch_cpu(idx);
grepsearch_tct = grepsearch_tct(idx);

grepsort_cpu = round(grepsort_cpu);
[~, idx] = unique(grepsort_cpu);
grepsort_cpu = grepsort_cpu(idx);
grepsort_tct = grepsort_tct(idx);

sort_cpu = round(sort_cpu);
[~, idx] = unique(sort_cpu);
sort_cpu = sort_cpu(idx);
sort_tct = sort_tct(idx);

kmeansiterator_cpu = round(kmeansiterator_cpu);
[~, idx] = unique(kmeansiterator_cpu);
kmeansiterator_cpu = kmeansiterator_cpu(idx);
kmeansiterator_tct = kmeansiterator_tct(idx);

kmeansclass_cpu = round(kmeansclass_cpu);
[~, idx] = unique(kmeansclass_cpu);
kmeansclass_cpu = kmeansclass_cpu(idx);
kmeansclass_tct = kmeansclass_tct(idx);