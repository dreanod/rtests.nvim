local ns = vim.api.nvim_create_namespace("rtests.nvim")

local display_test_results = function(results, bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  local failed = {}
  for _, result in ipairs(results) do
    if result.result == "expectation_success" then
      vim.api.nvim_buf_set_extmark(bufnr, ns, result.line_number - 1, 0, { virt_text = { { ""} } })
    elseif result.result == "expectation_failure" then
      table.insert(failed, {
        bufnr = bufnr,
        lnum = result.line_number - 1,
        col = 0,
        severity = vim.diagnostic.severity.ERROR,
        message = result.message,
        source = "testthat",
        user_data = {}
      })
    end
  end
  vim.diagnostic.set(ns, bufnr, failed, {
    virtual_text = {
      format = function(diag)
        return string.match(diag.message, "([^\n]*)")
      end
    }
  })
end

local test_r_file = function(bufnr)
  local content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local capture = false
  local test_nb = 1
  for i, line in ipairs(content) do
    if string.match(line, "^#'") then
      if capture then
        content[i] = string.gsub(line, "^#'", "")
      else
        if string.match(line, "@tests") then
          capture = true
          content[i] = "test_that(\"test " .. test_nb .. "\", {"
          test_nb = test_nb + 1
        else
          content[i] = ""
        end
      end
    else
      if capture then
        content[i] = "})"
        capture = false
      else
        content[i] = ""
      end
    end
  end
  local outfn = vim.api.nvim_buf_get_name(bufnr)
  outfn = vim.fs.dirname(outfn) .. '/.test-' .. vim.fs.basename(outfn)
  vim.fn.writefile(content, outfn)
  vim.fn.jobstart(
    "R --slave -e 'rtestNvim::test_logger(\"" .. outfn .. "\")'",
    { on_exit = function() 
        local s = io.open(outfn .. ".json"):read("*a")
        local results = vim.fn.json_decode(s)
        display_test_results(results, bufnr)
        vim.fn.system({ "rm", outfn, outfn .. ".json" })
      end 
    }
  )
end

local attach_to_buffer = function(bufnr)
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.R",
    callback = function()
      test_r_file(bufnr)
    end
  })
end

vim.api.nvim_create_user_command("RtestsOn", function()
  local bufnr = vim.api.nvim_get_current_buf()
  attach_to_buffer(bufnr)
  test_r_file(bufnr)
end, {})

vim.api.nvim_create_user_command("RtestsOff", function ()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  vim.diagnostic.set(ns, bufnr, {}, {})
  vim.api.nvim_command("autocmd! BufWritePost *.R")
end, {})
