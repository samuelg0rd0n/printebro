<?php

namespace App\Router;

use Nette;
use Nette\Application\Routers\RouteList;
use Nette\Application\Routers\Route;

use \Drahak\Restful\Application\Routes\CrudRoute;

class RouterFactory
{

	/** @var Nette\Http\Request */
	private $request;

	/**
	 * RouterFactory constructor.
	 */
	public function __construct(Nette\Http\Request $request)
	{
		$this->request = $request;
	}

	/**
	 * @return Nette\Application\IRouter
	 */
	public function createRouter()
	{
		$router = new RouteList;

		$webModule = new RouteList('Web');
		$router[] = $webModule;

		$webModule[] = new Route('<presenter>/<action>[/<id>]', 'Homepage:default');

		return $router;
	}

}
