<?php

namespace App\Modules;


abstract class BasePresenter extends \Nette\Application\UI\Presenter {

	use \Kdyby\Autowired\AutowireProperties;
	use \Kdyby\Autowired\AutowireComponentFactories;

	/************************
	 **** FLASH MESSAGES ****
	 ************************/

	public function flashMessage($message, $type = 'info')
	{
		$this->redrawControl('flashes');
		return parent::flashMessage($this->_($message), $type);
	}

	public function flashMessageError($message) {
		return $this->flashMessage($message, 'danger');
	}

	public function flashMessageWarning($message) {
		return $this->flashMessage($message, 'warning');
	}

	public function flashMessageSuccess($message) {
		return $this->flashMessage($message, 'success');
	}

	public function flashMessageInfo($message) {
		return $this->flashMessage($message, 'info');
	}

	/**
	 * Formats layout template file names.
	 * @return array
	 */
	public function formatLayoutTemplateFiles()
	{
		$list = parent::formatLayoutTemplateFiles();
		$dir = dirname($this->getReflection()->getFileName());
		$list[] = "$dir/../@layout.latte";
		return $list;
	}

	/**
	 * Formats view template file names.
	 * @return array
	 */
	public function formatTemplateFiles()
	{
		$list = parent::formatTemplateFiles();
		$dir = dirname($this->getReflection()->getFileName());
		$list[] = "$dir/$this->view.latte";
		return $list;
	}

}
