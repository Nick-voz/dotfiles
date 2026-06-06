return {
  "frankroeder/parrot.nvim",

  dependencies = { "ibhagwan/fzf-lua", "nvim-lua/plenary.nvim" },

  config = function()
    require("parrot").setup({
      providers = {
        perplexity = {
          name = "perplexity",
          api_key = os.getenv("PERPLEXITY_API_KEY"),
          endpoint = "https://api.perplexity.ai/chat/completions",
          headers = function(self)
            return {
              ["Content-Type"] = "application/json",
              ["Accept"] = "application/json",
              ["Authorization"] = "Bearer " .. self.api_key,
            }
          end,
          topic = {
            model = "r1-1776",
            params = {
              max_tokens = 64,
            },
          },
          models = {
            "sonar",
            "sonar-pro",
            "sonar-deep-research",
            "sonar-reasoning",
            "sonar-reasoning-pro",
            "r1-1776",
          },
        },
      },
      toggle_target = "popup",

      hooks = {
        CommitMsg = function(prt, params)
          local futils = require("parrot.file_utils")
          if futils.find_git_root() == "" then
            prt.logger.warning("Not in a git repository")
            return
          else
            local template = [[
          I want you to act as a commit message generator. I would like you 
          to generate an appropriate commit message using the conventional 
          commit format. Do not write any explanations or other words, just 
          reply with the commit message. Start with a short headline as
          summary but then list the individual changes in more detail.

          Here are the changes that should be considered by this message:
          ]] .. vim.fn.system("git diff --no-color --no-ext-diff --staged")
            local model_obj = prt.get_model("command")
            prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
          end
        end,

        SpellCheck = function(prt, params)
          local template = [[
        Your task is to take the text provided and rewrite it into a clear,
        grammatically correct version while preserving the original meaning
        as closely as possible. Correct any spelling mistakes, punctuation
        errors, verb tense issues, word choice problems, and other
        grammatical mistakes.

        After this respond just with the snippet of code that should be rewritten.

        Text:
        ```{{filetype}}
        {{selection}}
        ```
        ]]
          local model_obj = prt.get_model("command")
          prt.Prompt(params, prt.ui.Target.popup, model_obj, nil, template)
        end,
        WriteDocks = function(prt, params)
          local template = [[
            Generate detailed but concise documentation for this specific part of code:
            {{selection}}

            Context:
            ```{{filetype}}
            {{filecontent}}
            ```

            Please provide:
            1. Brief description (1-2 sentences about main purpose)
            2. Parameters/Arguments:
               - name: type - description
               - required/optional status
               - default values if any
            3. Return value:
               - type and description
               - possible return values/states
            4. Raises/Exceptions (if applicable):
               - what exceptions can be thrown
               - under what conditions
            6. Usage example (short)(optional)

            For classes additionally include:
            - Inheritance information
            - Class attributes
            - Public methods summary
            - Important internal methods (if any)

            Format as proper docstring for the given language.
            Use language-specific documentation style:
            - Python: Google style
            - JavaScript: JSDoc
            - Java: Javadoc
            etc.

            Keep it comprehensive but avoid redundant information.
            Focus on WHAT and WHY rather than HOW.

            Resalt MUST be just dockstnig for this specific part of code
            ]]
          local model_obj = prt.get_model("command")
          prt.Prompt(params, prt.ui.Target.popup, model_obj, nil, template)
        end,
        Review = function(prt, params)
          local template = [[
            Please analyze the following code snippet based on the criteria provided. Your evaluation should cover aspects of logic, optimization, adherence to best coding practices, and the precision of naming conventions.
            Code for Analysis:
            ```{{filetype}}
            {{selection}}
            ```
            Evaluation Criteria:
            Logic and Accuracy:
            Assess whether the code performs its intended function correctly.
            Identify any logical errors or potential issues that may arise in edge cases.
            Optimization:
            Evaluate the efficiency of the code.
            Suggest any areas where performance improvements could be made.
            Coding Standards:
            Check if the code adheres to typical coding standards and best practices.
            Point out any deviations from common practices in terms of structure and syntax.
            Naming Conventions:
            Analyze whether class, function, and variable names are descriptive and appropriate.
            Ensure that names are informative and reflect their roles accurately.
            Readability and Documentation:
            Consider the clarity and readability of the code.
            Review if comments and documentation sufficiently explain the code's purpose and function.
            Error Handling:
            Examine if the code includes appropriate error handling and validation.
            Detect any potential risks related to error management.
            Please provide a detailed review based on these criteria.
        ]]
          local model_obj = prt.get_model("command")
          prt.Prompt(params, prt.ui.Target.popup, model_obj, nil, template)
        end,
        UnitTests = function(prt, params)
          local template = [[
        I have the following code from {{filename}}:

        ```{{filetype}}
        {{selection}}
        ```

        Please respond by writing table driven unit tests for the code above.
        ]]
          local model_obj = prt.get_model("command")
          prt.logger.info("Creating unit tests for selection with model: " .. model_obj.name)
          prt.Prompt(params, prt.ui.Target.popup, model_obj, nil, template)
        end,
      },
    })

    vim.keymap.set("v", "<leader>ps", ":PrtSpellCheck<CR>", { desc = "Spell check with PrtSpellCheck" })
    vim.keymap.set("v", "<leader>pd", ":PrtWriteDocks<CR>", { desc = "Generate documentation for selected symbol" })
    vim.keymap.set("v", "<leader>pr", ":PrtReview<CR>", { desc = "Review selection" })
    vim.keymap.set(
      { "n", "v", "t" },
      "<leader>pcm",
      "<cmd>PrtCommitMsg<cr>",
      { desc = "Create commit message with AI" }
    )
    vim.keymap.set("v", "<leader>pt", ":PrtUnitTests<CR>", { desc = "write unit tests" })
  end,
}
