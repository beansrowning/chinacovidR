"""
Helper functions to help transform data post-NLP
"""
from functools import reduce
from itertools import islice
from collections import defaultdict

# Helper function to window iterate
def window(seq, n=2):
    """
    Returns a sliding window (of width n) over data from the iterable"
    "   s -> (s0,s1,...s[n-1]), (s1,s2,...,sn), ... 
    """
    it = iter(seq)
    result = tuple(islice(it, n))
    if len(result) == n:
        yield result
    for elem in it:
        result = result[1:] + (elem,)
        yield result

def get_case_counts(parsed_data: list):
    """
    Given a list of Docs, identify the localities and their case counts
    and return as a list of dicts
    """
    out = []

    for sent in parsed_data:
        sub_out = []
        dd_out = defaultdict(list)

        for tup in window(sent.ents, 2):
            prev_token = tup[0]
            ent = tup[1]
            
            numberish = prev_token.text.replace(",", "").isdigit()

            # If we find a province / city name
            if ent.label_ in ("ORG", "GPE", "LOC"):
                # and the previous token was number-like
                if prev_token[0].like_num and numberish:
                    # Append it to the list, with key equal to the location
                    # and the value
                    sub_out.append({ent.text: prev_token.text})
                

        # Grow each key (province / city) if there are multiple entries
        for dic in sub_out:
            for k, v in dic.items():
                # Convert text to int to avoid oddities with extend
                dd_out[k].extend([int(v.replace(",", ""))])
        out.append(dd_out)



    return out

def flatten_cases(cases: dict):
    out = cases.copy()
    for k, v in out.items():
        out.update({k: sum(v)})
    return out

def transpose_and_combine(dfs: list, metrics: list=["confirmed", "asymptomatic"]):
    """
    Given a list of Dfs in an expected order,
    transpose and column-bind
    """
    out_list = []
    for item in zip(dfs, metrics):
        df = item[0].T.reset_index()
        df.columns = ["Location", item[1]]
        out_list.append(df)
    
    out = reduce(lambda left,right: pd.merge(left, right, on='Location'), out_list)

    return out