{-# LANGUAGE TypeApplications #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Wasp.Analyzer.StdTypeDefinitions.Entity
  ( entityDeclTypeName,
  )
where

import Control.Arrow (left)
import Wasp.Analyzer.Evaluator.EvaluationError (mkEvaluationError)
import qualified Wasp.Analyzer.Evaluator.EvaluationError as ER
import qualified Wasp.Analyzer.Type as Type
import qualified Wasp.Analyzer.TypeChecker.AST as TC.AST
import Wasp.Analyzer.TypeDefinitions (DeclType (..), IsDeclType (..))
import qualified Wasp.AppSpec.Core.Decl as Decl
import Wasp.AppSpec.Entity (Entity, makeEntity)
import qualified Wasp.Psl.Parser.Model

instance IsDeclType Entity where
  declType =
    DeclType
      { dtName = entityDeclTypeName,
        dtBodyType = Type.QuoterType "psl",
        dtEvaluate = \typeDefinitions bindings declName expr ->
          Decl.makeDecl @Entity declName <$> declEvaluate typeDefinitions bindings expr
      }

  declEvaluate _ _ (TC.AST.WithCtx ctx expr) = case expr of
    TC.AST.PSL pslString ->
      left (ER.mkEvaluationError ctx . ER.ParseError . ER.EvaluationParseError) $
        makeEntity <$> Wasp.Psl.Parser.Model.parseBody pslString
    _ -> Left $ mkEvaluationError ctx $ ER.ExpectedType (Type.QuoterType "psl") (TC.AST.exprType expr)

entityDeclTypeName :: String
entityDeclTypeName = "entity"
