defmodule Eecrit.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use Eecrit.Web, :controller
      use Eecrit.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def model do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      # TODO: Wanted to put this in UserAbilities, but I get a bizarre
      # error when I do the include:
      #
      #       == Compilation error on file web/views/old_procedure_description_view.ex ==
      # ** (CompileError) web/views/old_procedure_description_view.ex:2: module Eecrit.Router.Helpers is not loaded and could not be found
      #     expanding macro: Eecrit.Web.__using__/1
      #     web/views/old_procedure_description_view.ex:2: Eecrit.OldProcedureDescriptionView (module)
      #     (elixir) expanding macro: Kernel.use/2
      #     web/views/old_procedure_description_view.ex:2: Eecrit.OldProcedureDescriptionView (module)
      import Eecrit.ModelMacros
    end
  end

  def controller do
    quote do
      use Phoenix.Controller

      alias Eecrit.Repo
      alias Eecrit.OldRepo
      import Ecto
      import Ecto.Query

      import Eecrit.Router.Helpers
      import Eecrit.Gettext
      import Canada.Can, only: [can?: 3]
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "web/templates"

      alias Phoenix.Controller

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import Eecrit.Router.Helpers
      import Eecrit.ErrorHelpers
      import Eecrit.Gettext
      import Canada.Can, only: [can?: 3]
      alias Eecrit.ModelDisplays
      alias Eecrit.ViewModel.Protocol, as: VMP
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias Eecrit.Repo
      alias Eecrit.OldRepo
      import Ecto
      import Ecto.Query
      import Eecrit.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
