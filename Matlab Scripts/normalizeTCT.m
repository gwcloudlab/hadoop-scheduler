
%% Remove tct and cpu values from dedicated nodes, i.e. for which cpu util is < 1
pi_tct(pi_cpu<1) = [];
wc_tct(wc_cpu<1) = [];
sort_tct(sort_cpu<1) = [];
terasort_tct(terasort_cpu<1) = [];
grepsort_tct(grepsort_cpu<1) = [];
grepsearch_tct(grepsearch_cpu<1) = [];
kmeansiterator_tct(kmeansiterator_cpu<1) = [];
kmeansclass_tct(kmeansclass_cpu<1) = [];

pi_cpu(pi_cpu<1) = [];
wc_cpu(wc_cpu<1) = [];
sort_cpu(sort_cpu<1) = [];
terasort_cpu(terasort_cpu<1) = [];
grepsort_cpu(grepsort_cpu<1) = [];
grepsearch_cpu(grepsearch_cpu<1) = [];
kmeansiterator_cpu(kmeansiterator_cpu<1) = [];
kmeansclass_cpu(kmeansclass_cpu<1) = [];

%% Normalize the tct values with the values from shared nodes
sort_tct = sort_tct./mean(sort_normalize);
terasort_tct = terasort_tct./mean(terasort_normalize);
wc_tct = wc_tct./mean(wc_normalize);
pi_tct = pi_tct./mean(pi_normalize);
grepsearch_tct = grepsearch_tct./mean(grepsearch_normalize);
grepsort_tct = grepsort_tct./mean(grepsort_normalize);
kmeansiterator_tct = kmeansiterator_tct./mean(kmeansiterator_normalize);
kmeansclass_tct = kmeansclass_tct./mean(kmeansclass_normalize);


% tpcw_sort_tct = tpcw_sort_tct./median(tpcw_sort_normalize);
% tpcw_terasort_tct = tpcw_terasort_tct./median(tpcw_terasort_normalize);
% tpcw_wc_tct = tpcw_wc_tct./median(tpcw_wc_normalize);
% tpcw_pi_tct = tpcw_pi_tct./median(tpcw_pi_normalize);
% tpcw_grepsearch_tct = tpcw_grepsearch_tct./median(tpcw_grepsearch_normalize);
% tpcw_grepsort_tct = tpcw_grepsort_tct./median(tpcw_grepsort_normalize);
% tpcw_kmeansiterator_tct = tpcw_kmeansiterator_tct./median(tpcw_kmeansiterator_normalize);
% tpcw_kmeansclass_tct = tpcw_kmeansclass_tct./median(tpcw_kmeansclass_normalize);
