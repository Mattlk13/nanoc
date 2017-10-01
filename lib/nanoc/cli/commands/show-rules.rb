# frozen_string_literal: true

usage 'show-rules [thing]'
aliases :explain
summary 'describe the rules for each item'
description "
Prints the rules used for all items and layouts in the current site.
"

module Nanoc::CLI::Commands
  class ShowRules < ::Nanoc::CLI::CommandRunner
    def run
      site = load_site

      reps = build_reps(site: site)

      action_provider = Nanoc::Int::ActionProvider.named(:rule_dsl).for(site)
      rules = action_provider.rules_collection

      items = site.items.sort_by(&:identifier)
      layouts = site.layouts.sort_by(&:identifier)

      items.each   { |e| explain_item(e, rules: rules, reps: reps) }
      layouts.each { |e| explain_layout(e, rules: rules) }
    end

    def build_reps(site:)
      site.compiler.tap(&:build_reps).reps
    end

    def explain_item(item, rules:, reps:)
      puts(fmt_heading("Item #{item.identifier}") + ':')

      reps[item].each do |rep|
        rule = rules.compilation_rule_for(rep)
        puts "  Rep #{rep.name}: #{rule ? rule.pattern : '(none)'}"
      end

      puts
    end

    def explain_layout(layout, rules:)
      puts(fmt_heading("Layout #{layout.identifier}") + ':')

      found = false
      rules.layout_filter_mapping.each_key do |pattern|
        if pattern.match?(layout.identifier)
          puts "  #{pattern}"
          found = true
          break
        end
      end
      unless found
        puts '  (none)'
      end

      puts
    end

    def fmt_heading(s)
      Nanoc::CLI::ANSIStringColorizer.c(s, :bold, :yellow)
    end
  end
end

runner Nanoc::CLI::Commands::ShowRules
