import plotly.graph_objects as go
import plotly.subplots as sp
import plotly
import pandas as pd
import numpy as np
import json
import textwrap
from models import PollSample


def render_plot(polls_results_db):
    """
    :param polls_results_db: list of PollResult objects (db query)
    :return: plotly json object
    """
    titles = []
    sz = 0
    for poll_res in polls_results_db:
        sample = PollSample.query.filter_by(id=poll_res.poll_sample_id).first()
        titles.append(sample.question)
        sz += 1
    if sz == 0:
        return None
    cols_amount = 2
    rows_amount = sz // cols_amount + (sz % cols_amount != 0)

    new_titles = []
    title_width = 44
    for i in range(len(titles)):
        new_titles.append(textwrap.fill(titles[i], title_width).replace("\n", "<br>"))

    plot = sp.make_subplots(rows=rows_amount, cols=cols_amount, subplot_titles=new_titles,
                            specs=[[{"type": "domain"}, {"type": "domain"}] for _ in range(rows_amount)])
    content = False
    for i, poll_res in enumerate(polls_results_db):
        answers = json.loads(poll_res.answers)
        if answers is None:
            continue
        content = True
        df = pd.DataFrame(answers, index=["key"])
        df = pd.DataFrame(np.vstack([df.columns, df])).T
        df = df.rename({0: 'answer', 1: 'count'}, axis=1)

        labels = list(df['answer'])
        values = list(df['count'])
        zeros = [True if values[i] == 0 else False for i in range(len(values))]
        if len(labels) - zeros.count(True) == 0 or len(values) - zeros.count(True) == 0:
            continue
        pull = [0 for _ in range(len(labels))]
        sample = PollSample.query.filter_by(id=poll_res.poll_sample_id).first()
        if sample.poll_type == "quiz":
            correct = sample.correct_answer
            answer_variants = json.loads(sample.answer_variants)
            correct_index = labels.index(answer_variants[correct])
            if not (zeros.count(False) == 1 and not zeros[correct_index]):
                pull[correct_index] = 0.1
        final_labels = [labels[i] for i in range(len(labels)) if not zeros[i]]
        final_values = [values[i] for i in range(len(values)) if not zeros[i]]
        final_pull = [pull[i] for i in range(len(pull)) if not zeros[i]]
        plot.add_trace(go.Pie(labels=final_labels, values=final_values, pull=final_pull), row=i // cols_amount + 1,
                       col=i % cols_amount + 1)
    if not content:
        return None
    width = 300
    height = 300 + 150
    plot.update_layout(height=height * rows_amount, width=3 * width + 100, showlegend=False)
    plot.update_annotations(width=width + 30, font_size=13)
    graphJSON = json.dumps(plot, cls=plotly.utils.PlotlyJSONEncoder)
    return graphJSON