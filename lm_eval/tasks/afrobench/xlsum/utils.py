import argparse
import os

import yaml


def prompt_func(mode, lang):
    if lang == "pidgin":
        lang = "Nigerian Pidgin"

    prompt_map = {
        "prompt_1": f"Provide a summary of the document written in {lang.capitalize()}. Ensure that you provide the summary in {lang.capitalize()} and nothing else.\n"
        f"Document in {lang.capitalize()}: " + r"{{'text'}}\n"
        "Summary: ",
        "prompt_2": "Summarize the document below in triple backticks and return only the summary and nothing else.\n"
        + r"```{{'text'}}```\n",
        "prompt_3": f"You are an advanced Summarizer, a specialized assistant designed to summarize documents in {lang.capitalize()}. "
        f"Your main goal is to ensure summaries are concise and informative. Ensure you return the summary only and nothing else.\n"
        f"Document: " + r"{{'text'}}\n"
        "Summary: ",
        "prompt_4": f"Summarize this {lang.capitalize()} document:\n" + r"{{'text'}}\n"
        "Summary: ",
        "prompt_5": f"{lang.capitalize()} document: " + r"{{'text'}}\n" "Summary: ",
    }
    return prompt_map[mode]


def gen_lang_yamls(output_dir: str, overwrite: bool, mode: str) -> None:
    """
    Generate a yaml file for each language.

    :param output_dir: The directory to output the files to.
    :param overwrite: Whether to overwrite files if they already exist.
    """
    err = []
    XLSUM_LANGUAGES = (
        "amharic",
        "arabic",
        "hausa",
        "igbo",
        "kirundi",
        "oromo",
        "pidgin",
        "somali",
        "swahili",
        "telugu",
        "tigrinya",
        "yoruba",
    )

    for lang in XLSUM_LANGUAGES:
        try:
            file_name = f"xlsum_{lang}.yaml"
            task_name = f"xlsum_{lang}_{mode}"
            yaml_template = "xlsum"
            yaml_details = {
                "include": yaml_template,
                "task": task_name,
                "dataset_name": lang,
                "doc_to_text": prompt_func(mode, lang),
                "doc_to_target": "{{summary}}",
            }
            file_path = os.path.join(output_dir, mode)
            os.makedirs(file_path, exist_ok=True)

            with open(
                f"{output_dir}/{mode}/{file_name}",
                "w" if overwrite else "x",
                encoding="utf8",
            ) as f:
                f.write("# Generated by utils.py\n")
                yaml.dump(
                    yaml_details,
                    f,
                    allow_unicode=True,
                )
        except FileExistsError:
            err.append(file_name)

    if len(err) > 0:
        raise FileExistsError(
            "Files were not created because they already exist (use --overwrite flag):"
            f" {', '.join(err)}"
        )


def main() -> None:
    """Parse CLI args and generate language-specific yaml files."""
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--overwrite",
        default=True,
        action="store_true",
        help="Overwrite files if they already exist",
    )
    parser.add_argument(
        "--output-dir",
        default="./",
        help="Directory to write yaml files to",
    )

    PROMPT_CHOICES = ["prompt_1", "prompt_2", "prompt_3", "prompt_4", "prompt_5"]
    parser.add_argument(
        "--mode",
        nargs="*",
        default=PROMPT_CHOICES,
        choices=PROMPT_CHOICES,
        help="Prompt number(s)",
    )
    args = parser.parse_args()

    for mode in args.mode:
        gen_lang_yamls(output_dir=args.output_dir, overwrite=args.overwrite, mode=mode)


if __name__ == "__main__":
    main()
