import spacy
import pandas as pd
from nhcNlp.helpers import get_case_counts, flatten_cases, transpose_and_combine

# Load in Spacy
nlp = spacy.load("en_core_web_sm")

def extract_case_counts(raw_text: str):
    # Using English language model 
    parsed_content = nlp(raw_text)

    parsed_split = list(parsed_content.sents)
    
    case_counts = get_case_counts(parsed_split)
    flat_cases = [flatten_cases(a) for a in case_counts if len(a) > 0]
    frames = [pd.DataFrame(a, index = ["cases"]) for a in flat_cases]

    out = transpose_and_combine(frames)

    return out